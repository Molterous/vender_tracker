import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:vender_tracker/common/enums/user_roles_enum.dart';
import 'package:vender_tracker/common/models/tasks.dart';
import 'package:vender_tracker/main.dart';
import '../common/models/quotation.dart';
import 'package:to_csv/to_csv.dart' as exportCSV;

class NewQuotationScreen extends StatefulWidget {
  final List<Tasks> tasks;
  final Quotation? quotation;

  const NewQuotationScreen({
    super.key,
    required this.tasks,
    this.quotation,
  });

  @override
  State<NewQuotationScreen> createState() => _NewQuotationScreenState();
}

class _NewQuotationScreenState extends State<NewQuotationScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _noteController;

  // pair(service name and service price)
  final List<Map<ControllerKeys, TextEditingController>> _itemsController = [];
  final List<Map<ControllerKeys, bool>> _check = [];
  final List<bool> _itemsExpanded = [];

  Tasks? _selectedTask;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.quotation?.name);
    _descController = TextEditingController(text: widget.quotation?.info);
    _noteController = TextEditingController(text: widget.quotation?.note);

    try {
      _selectedTask = widget.quotation != null
          ? widget.tasks.firstWhere((e) => e.taskId == widget.quotation!.taskId)
          : null;
    } catch (e) {
      debugPrint(e.toString());
    }

    widget.quotation?.serviceName.forEach((key, value) {
      _itemsExpanded.add(false);

      _itemsController.add({
        ControllerKeys.service: TextEditingController(text: value),
        ControllerKeys.type: TextEditingController(text: widget.quotation!.serviceType[key]),
        ControllerKeys.bankCharges: TextEditingController(text: widget.quotation!.serviceCharges[key]),
        ControllerKeys.units: TextEditingController(text: widget.quotation!.serviceUnit[key]),
        ControllerKeys.docketCharges: TextEditingController(text: widget.quotation!.docketCharges[key]),
        ControllerKeys.hamaliCharges: TextEditingController(text: widget.quotation!.hamaliCharges[key]),
        ControllerKeys.doorDelivery: TextEditingController(text: widget.quotation!.doorDelivery[key]),
        ControllerKeys.pfCharges: TextEditingController(text: widget.quotation!.pfCharges[key]),
        ControllerKeys.greenTaxCharge: TextEditingController(text: widget.quotation!.greenTaxCharge[key]),
        ControllerKeys.fovCharges: TextEditingController(text: widget.quotation!.fovCharges[key]),
        ControllerKeys.gstCharges: TextEditingController(text: widget.quotation!.gstCharges[key]),
        ControllerKeys.otherCharges: TextEditingController(text: widget.quotation!.otherCharges[key]),
        ControllerKeys.remark: TextEditingController(text: widget.quotation!.serviceRemark[key]),
        ControllerKeys.totalCharges: TextEditingController(text: widget.quotation!.totalCharges[key]),
      });

      _check.add({
        ControllerKeys.service: false,
        ControllerKeys.type: false,
        ControllerKeys.bankCharges: false,
        ControllerKeys.units: false,
        ControllerKeys.docketCharges: (widget.quotation!.docketCharges[key] ?? '').isNotEmpty,
        ControllerKeys.hamaliCharges: (widget.quotation!.hamaliCharges[key] ?? '').isNotEmpty,
        ControllerKeys.doorDelivery: (widget.quotation!.doorDelivery[key] ?? '').isNotEmpty,
        ControllerKeys.pfCharges: (widget.quotation!.pfCharges[key] ?? '').isNotEmpty,
        ControllerKeys.greenTaxCharge: (widget.quotation!.greenTaxCharge[key] ?? '').isNotEmpty,
        ControllerKeys.fovCharges: (widget.quotation!.fovCharges[key] ?? '').isNotEmpty,
        ControllerKeys.gstCharges: (widget.quotation!.gstCharges[key] ?? '').isNotEmpty,
        ControllerKeys.otherCharges: (widget.quotation!.otherCharges[key] ?? '').isNotEmpty,
        ControllerKeys.remark: (widget.quotation!.serviceRemark[key] ?? '').isNotEmpty,
        ControllerKeys.totalCharges: (widget.quotation!.totalCharges[key] ?? '').isNotEmpty,
      });
    });

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _noteController.dispose();

    for (var ele in _itemsController) {
      for (var element in ele.values) {
        element.dispose();
      }
    }

    super.dispose();
  }

  void _submit() {
    try {
      if (_formKey.currentState!.validate() && _selectedTask != null) {
        // final List<Map<String, String>> itemMap = [];
        Map<String, String> serviceName = {},
            serviceType = {},
            serviceCharges = {},
            serviceUnit = {},
            totalCharges = {},
            serviceRemark = {},
            docketCharges = {},
            hamaliCharges = {},
            doorDelivery = {},
            pfCharges = {},
            greenTaxCharge = {},
            fovCharges = {},
            gstCharges = {},
            otherCharges = {};

        for (var idx = 0; idx < _itemsController.length; idx++) {

          final i = _itemsController[idx];

          serviceName[idx.toString()]     =    i[ControllerKeys.service]!.text;
          serviceType[idx.toString()]     =    i[ControllerKeys.type]!.text;
          serviceCharges[idx.toString()]  =    i[ControllerKeys.bankCharges]!.text;
          serviceUnit[idx.toString()]     =    i[ControllerKeys.units]!.text;
          totalCharges[idx.toString()]    =    i[ControllerKeys.totalCharges]!.text;
          serviceRemark[idx.toString()]   =    i[ControllerKeys.remark]!.text;
          docketCharges[idx.toString()]   =    i[ControllerKeys.docketCharges]!.text;
          hamaliCharges[idx.toString()]   =    i[ControllerKeys.hamaliCharges]!.text;
          doorDelivery[idx.toString()]    =    i[ControllerKeys.doorDelivery]!.text;
          pfCharges[idx.toString()]       =    i[ControllerKeys.pfCharges]!.text;
          greenTaxCharge[idx.toString()]  =    i[ControllerKeys.greenTaxCharge]!.text;
          fovCharges[idx.toString()]      =    i[ControllerKeys.fovCharges]!.text;
          gstCharges[idx.toString()]      =    i[ControllerKeys.gstCharges]!.text;
          otherCharges[idx.toString()]    =    i[ControllerKeys.otherCharges]!.text;

        }

        Navigator.pop(
          context,
          Quotation(
            quotationId: widget.quotation?.quotationId ?? '',
            name: _titleController.text,
            info: _descController.text,
            note: _noteController.text,
            taskId: _selectedTask!.taskId,
            worker: _selectedTask!.worker,
            modifiedDate: DateTime.now().toString(),
            docketCharges: docketCharges,
            doorDelivery: doorDelivery,
            fovCharges: fovCharges,
            greenTaxCharge: greenTaxCharge,
            gstCharges: gstCharges,
            hamaliCharges: hamaliCharges,
            otherCharges: otherCharges,
            pfCharges: pfCharges,
            serviceCharges: serviceCharges,
            serviceName: serviceName,
            serviceRemark: serviceRemark,
            serviceType: serviceType,
            serviceUnit: serviceUnit,
            totalCharges: totalCharges,
          ),
        );
      }
    } catch (_) {
      Fluttertoast.showToast(
        msg: "Please fill all fields correctly, before submitting",
        textColor: Colors.white,
        backgroundColor: Colors.red,
      );
    }
  }

  void _changeTotal(int index) {

    final item = _itemsController[index];
    final check = _check[index];

    double total = (double.tryParse(item[ControllerKeys.bankCharges]!.text) ?? 0.0) *
        (double.tryParse(item[ControllerKeys.units]!.text) ?? 0.0);

    if (check[ControllerKeys.gstCharges]! &&
        item[ControllerKeys.gstCharges]!.text.isNotEmpty) {
      total += (total * ((double.tryParse(item[ControllerKeys.gstCharges]!.text) ?? 0.0)/100));
    }

    if (check[ControllerKeys.docketCharges]! &&
        item[ControllerKeys.docketCharges]!.text.isNotEmpty) {
      total += double.tryParse(item[ControllerKeys.docketCharges]!.text) ?? 0.0;
    }

    if (check[ControllerKeys.hamaliCharges]! &&
        item[ControllerKeys.hamaliCharges]!.text.isNotEmpty) {
      total += double.tryParse(item[ControllerKeys.hamaliCharges]!.text) ?? 0.0;
    }

    if (check[ControllerKeys.doorDelivery]! &&
        item[ControllerKeys.doorDelivery]!.text.isNotEmpty) {
      total += double.tryParse(item[ControllerKeys.doorDelivery]!.text) ?? 0.0;
    }

    if (check[ControllerKeys.pfCharges]! &&
        item[ControllerKeys.pfCharges]!.text.isNotEmpty) {
      total += double.tryParse(item[ControllerKeys.pfCharges]!.text) ?? 0.0;
    }

    if (check[ControllerKeys.greenTaxCharge]! &&
        item[ControllerKeys.greenTaxCharge]!.text.isNotEmpty) {
      total += double.tryParse(item[ControllerKeys.greenTaxCharge]!.text) ?? 0.0;
    }

    if (check[ControllerKeys.fovCharges]! &&
        item[ControllerKeys.fovCharges]!.text.isNotEmpty) {
      total += double.tryParse(item[ControllerKeys.fovCharges]!.text) ?? 0.0;
    }

    if (check[ControllerKeys.otherCharges]! &&
        item[ControllerKeys.otherCharges]!.text.isNotEmpty) {
      total += double.tryParse(item[ControllerKeys.otherCharges]!.text) ?? 0.0;
    }

    setState(() => item[ControllerKeys.totalCharges]!.text = total.toString() );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = globalActiveUser!.role == UserRolesEnum.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.quotation == null
              ? l10n.createQuotation
              : l10n.updateQuotation,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: !isAdmin
            ? null
            : [
                Container(
                  margin: const EdgeInsets.only(right: 20),
                  child: InkWell(
                    onTap: () {
                      if (_itemsController.isEmpty) { return; }

                      List<String> header = [];
                      header.add('S.No.');
                      header.add('Service');
                      header.add('Type');
                      header.add('Charges');
                      header.add('Unit');
                      header.add('GST %age');
                      header.add('Docket Charges');
                      header.add('Hamali Charges');
                      header.add('Door Delivery Charges');
                      header.add('PF Charges');
                      header.add('Green Tax Charges');
                      header.add('FOV Charges');
                      header.add('Other Charges');
                      header.add('Remark');
                      header.add('Total');

                      List<List<String>> listOfLists = [];

                      for (var i = 0; i < _itemsController.length; i++) {
                        final item = _itemsController[i];

                        List<String> data = [
                          '${i + 1}',
                          item[ControllerKeys.service]!.text,
                          item[ControllerKeys.type]!.text,
                          item[ControllerKeys.bankCharges]!.text,
                          item[ControllerKeys.units]!.text,
                          item[ControllerKeys.gstCharges]!.text,
                          item[ControllerKeys.docketCharges]!.text,
                          item[ControllerKeys.hamaliCharges]!.text,
                          item[ControllerKeys.doorDelivery]!.text,
                          item[ControllerKeys.pfCharges]!.text,
                          item[ControllerKeys.greenTaxCharge]!.text,
                          item[ControllerKeys.fovCharges]!.text,
                          item[ControllerKeys.otherCharges]!.text,
                          item[ControllerKeys.remark]!.text,
                          item[ControllerKeys.totalCharges]!.text,
                        ];
                        listOfLists.add(data);
                      }

                      exportCSV.myCSV(header, listOfLists);
                    },
                    child: const Icon(Icons.share),
                  ),
                ),
              ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // company name
              ...[
                _buildTextField(
                  _titleController,
                  l10n.companyName,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
              ],

              // Company info
              ...[
                _buildTextField(
                  _descController,
                  l10n.companyInfo,
                  maxLines: 3,
                ),
                const SizedBox(height: 10),
              ],

              // list items
              if (_itemsController.isNotEmpty) ...[
                Text(
                  l10n.services,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),

                // item list
                _buildItemsList(context, isAdmin),
                const SizedBox(height: 10),
              ],

              // Insert new entry field
              if (isAdmin) ...[
                InkWell(
                  onTap: () {
                    setState(() {
                      _itemsExpanded.add(false);
                      _check.add({
                        ControllerKeys.service: false,
                        ControllerKeys.type: false,
                        ControllerKeys.bankCharges: false,
                        ControllerKeys.units: false,
                        ControllerKeys.docketCharges: false,
                        ControllerKeys.hamaliCharges: false,
                        ControllerKeys.doorDelivery: false,
                        ControllerKeys.pfCharges: false,
                        ControllerKeys.greenTaxCharge: false,
                        ControllerKeys.fovCharges: false,
                        ControllerKeys.gstCharges: false,
                        ControllerKeys.otherCharges: false,
                        ControllerKeys.remark: false,
                        ControllerKeys.totalCharges: false,
                      });

                      _itemsController.add({
                        ControllerKeys.service: TextEditingController(),
                        ControllerKeys.type: TextEditingController(),
                        ControllerKeys.bankCharges: TextEditingController(),
                        ControllerKeys.units: TextEditingController(),
                        ControllerKeys.docketCharges: TextEditingController(),
                        ControllerKeys.hamaliCharges: TextEditingController(),
                        ControllerKeys.doorDelivery: TextEditingController(),
                        ControllerKeys.pfCharges: TextEditingController(),
                        ControllerKeys.greenTaxCharge: TextEditingController(),
                        ControllerKeys.fovCharges: TextEditingController(),
                        ControllerKeys.gstCharges: TextEditingController(),
                        ControllerKeys.otherCharges: TextEditingController(),
                        ControllerKeys.remark: TextEditingController(),
                        ControllerKeys.totalCharges: TextEditingController(),
                      });
                    });
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      color: Colors.black45,
                    ),
                    child: Text(
                      l10n.insertNewEntryField,
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],

              // task selection drop down
              if (isAdmin) ...[
                DropdownButtonFormField<Tasks>(
                  value: _selectedTask,
                  decoration: InputDecoration(
                    labelText: l10n.assignWith,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    filled: true,
                    fillColor: Colors.grey[100],
                  ),
                  items: widget.tasks.map((task) {
                    return DropdownMenuItem<Tasks>(
                      value: task,
                      child: SizedBox(
                        width: width * 0.8,
                        child: Text(
                          '${task.title} (${task.taskId})',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedTask = value),
                  validator: (value) =>
                      value == null ? l10n.pleaseSelectTask : null,
                ),
                const SizedBox(height: 15),
              ],

              // note
              ...[
                _buildTextField(
                  _noteController,
                  l10n.notes,
                  maxLines: 2,
                ),
                const SizedBox(height: 10),
              ],

              // save button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(
                    l10n.saveDetails,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label, {
    int maxLines = 1,
    bool enabled = true,
    bool isNumKeys = false,
    VoidCallback? onChange,
  }) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: isNumKeys ? TextInputType.number : null,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: (value) =>
          value == null || value.isEmpty ? l10n.fieldRequired(label) : null,
      onChanged: (_) => onChange?.call(),
    );
  }

  Widget _buildItemsList(BuildContext context, [bool isAdmin = false]) {
    final l10n = AppLocalizations.of(context)!;

    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _itemsController.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = _itemsController[index];
        final check = _check[index];

        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // service name and expandable widget
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                item[ControllerKeys.service]!,
                                l10n.service,
                                maxLines: 1,
                                enabled: _itemsExpanded[index],
                              ),
                            ),
                            const SizedBox(width: 4),

                            // expandable list
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _itemsExpanded[index] =
                                      !_itemsExpanded[index];
                                });
                              },
                              child: !_itemsExpanded[index]
                                  ? const Icon(Icons.keyboard_arrow_down)
                                  : const Icon(Icons.keyboard_arrow_up),
                            ),
                          ],
                        ),

                        // rest fields
                        if (_itemsExpanded[index]) ...[
                          const SizedBox(height: 12),
                          _buildTextField(
                            item[ControllerKeys.type]!,
                            l10n.type,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 12),

                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  item[ControllerKeys.bankCharges]!,
                                  l10n.charges,
                                  maxLines: 1,
                                  isNumKeys: true,
                                  onChange: () => _changeTotal(index),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: _buildTextField(
                                  item[ControllerKeys.units]!,
                                  l10n.units,
                                  maxLines: 1,
                                  isNumKeys: true,
                                  onChange: () => _changeTotal(index),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // gst field
                          Row(
                            children: [
                              Checkbox(
                                onChanged: (_) {
                                  setState(() {
                                    _check[index][ControllerKeys.gstCharges] =
                                        !_check[index]
                                            [ControllerKeys.gstCharges]!;
                                  });
                                  _changeTotal(index);
                                },
                                value: check[ControllerKeys.gstCharges],
                              ),
                              const SizedBox(width: 8),
                              check[ControllerKeys.gstCharges]!
                                  ? Expanded(
                                      child: _buildTextField(
                                        item[ControllerKeys.gstCharges]!,
                                        'GST %age',
                                        maxLines: 1,
                                        isNumKeys: true,
                                        onChange: () => _changeTotal(index),
                                      ),
                                    )
                                  : const Text("Add GST Charges"),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // docket Charges field
                          Row(
                            children: [
                              Checkbox(
                                onChanged: (_) {
                                  setState(() {
                                    _check[index]
                                            [ControllerKeys.docketCharges] =
                                        !_check[index]
                                            [ControllerKeys.docketCharges]!;
                                  });
                                  _changeTotal(index);
                                },
                                value: check[ControllerKeys.docketCharges],
                              ),
                              const SizedBox(width: 8),
                              check[ControllerKeys.docketCharges]!
                                  ? Expanded(
                                      child: _buildTextField(
                                        item[ControllerKeys.docketCharges]!,
                                        'Docket Charges',
                                        maxLines: 1,
                                        isNumKeys: true,
                                        onChange: () => _changeTotal(index),
                                      ),
                                    )
                                  : const Text("Add Docket Charges"),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Hamali Charges field
                          Row(
                            children: [
                              Checkbox(
                                onChanged: (_) {
                                  setState(() {
                                    _check[index]
                                            [ControllerKeys.hamaliCharges] =
                                        !_check[index]
                                            [ControllerKeys.hamaliCharges]!;
                                  });
                                  _changeTotal(index);
                                },
                                value: check[ControllerKeys.hamaliCharges],
                              ),
                              const SizedBox(width: 8),
                              check[ControllerKeys.hamaliCharges]!
                                  ? Expanded(
                                      child: _buildTextField(
                                        item[ControllerKeys.hamaliCharges]!,
                                        'Hamali Charges',
                                        maxLines: 1,
                                        isNumKeys: true,
                                        onChange: () => _changeTotal(index),
                                      ),
                                    )
                                  : const Text("Add Hamali Charges"),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Door Delivery field
                          Row(
                            children: [
                              Checkbox(
                                onChanged: (_) {
                                  setState(() {
                                    _check[index][ControllerKeys.doorDelivery] =
                                        !_check[index]
                                            [ControllerKeys.doorDelivery]!;
                                  });
                                  _changeTotal(index);
                                },
                                value: check[ControllerKeys.doorDelivery],
                              ),
                              const SizedBox(width: 8),
                              check[ControllerKeys.doorDelivery]!
                                  ? Expanded(
                                      child: _buildTextField(
                                        item[ControllerKeys.doorDelivery]!,
                                        'Door Delivery Charges',
                                        maxLines: 1,
                                        isNumKeys: true,
                                        onChange: () => _changeTotal(index),
                                      ),
                                    )
                                  : const Text("Add Door Delivery Charges"),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Pf Charges field
                          Row(
                            children: [
                              Checkbox(
                                onChanged: (_) {
                                  setState(() {
                                    _check[index][ControllerKeys.pfCharges] =
                                        !_check[index]
                                            [ControllerKeys.pfCharges]!;
                                  });
                                  _changeTotal(index);
                                },
                                value: check[ControllerKeys.pfCharges],
                              ),
                              const SizedBox(width: 8),
                              check[ControllerKeys.pfCharges]!
                                  ? Expanded(
                                      child: _buildTextField(
                                        item[ControllerKeys.pfCharges]!,
                                        'PF Charges',
                                        maxLines: 1,
                                        isNumKeys: true,
                                        onChange: () => _changeTotal(index),
                                      ),
                                    )
                                  : const Text("Add PF Charges"),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Green Tax Charge field
                          Row(
                            children: [
                              Checkbox(
                                onChanged: (_) {
                                  setState(() {
                                    _check[index]
                                            [ControllerKeys.greenTaxCharge] =
                                        !_check[index]
                                            [ControllerKeys.greenTaxCharge]!;
                                  });
                                  _changeTotal(index);
                                },
                                value: check[ControllerKeys.greenTaxCharge],
                              ),
                              const SizedBox(width: 8),
                              check[ControllerKeys.greenTaxCharge]!
                                  ? Expanded(
                                      child: _buildTextField(
                                        item[ControllerKeys.greenTaxCharge]!,
                                        'Green Tax Charges',
                                        maxLines: 1,
                                        isNumKeys: true,
                                        onChange: () => _changeTotal(index),
                                      ),
                                    )
                                  : const Text("Add Green Tax Charges"),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // fov Charges field
                          Row(
                            children: [
                              Checkbox(
                                onChanged: (_) {
                                  setState(() {
                                    _check[index][ControllerKeys.fovCharges] =
                                        !_check[index]
                                            [ControllerKeys.fovCharges]!;
                                  });
                                  _changeTotal(index);
                                },
                                value: check[ControllerKeys.fovCharges],
                              ),
                              const SizedBox(width: 8),
                              check[ControllerKeys.fovCharges]!
                                  ? Expanded(
                                      child: _buildTextField(
                                        item[ControllerKeys.fovCharges]!,
                                        'FOV Charges',
                                        maxLines: 1,
                                        isNumKeys: true,
                                        onChange: () => _changeTotal(index),
                                      ),
                                    )
                                  : const Text("Add FOV Charges"),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Other Charges field
                          Row(
                            children: [
                              Checkbox(
                                onChanged: (_) {
                                  setState(() {
                                    _check[index][ControllerKeys.otherCharges] =
                                        !_check[index]
                                            [ControllerKeys.otherCharges]!;
                                  });
                                  _changeTotal(index);
                                },
                                value: check[ControllerKeys.otherCharges],
                              ),
                              const SizedBox(width: 8),
                              check[ControllerKeys.otherCharges]!
                                  ? Expanded(
                                      child: _buildTextField(
                                        item[ControllerKeys.otherCharges]!,
                                        'Other Charges',
                                        maxLines: 1,
                                        isNumKeys: true,
                                        onChange: () => _changeTotal(index),
                                      ),
                                    )
                                  : const Text("Add Other Charges"),
                            ],
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            item[ControllerKeys.remark]!,
                            l10n.remark,
                            maxLines: 1,
                          ),
                          const SizedBox(height: 12),

                          _buildTextField(
                            item[ControllerKeys.totalCharges]!,
                            l10n.total,
                            maxLines: 1,
                            isNumKeys: true,
                            enabled: false,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // remove tile btn
            if (isAdmin) ...[
              const SizedBox(width: 10),
              InkWell(
                onTap: () => setState(() => _itemsController.removeAt(index)),
                child: const Icon(Icons.delete),
              ),
            ],
          ],
        );
      },
    );
  }
}

enum ControllerKeys {
  service("service"),
  type("type"),
  bankCharges("bankCharges"),
  units("units"),
  docketCharges("docketCharges"),
  hamaliCharges("hamaliCharges"),
  doorDelivery("doorDelivery"),
  pfCharges("pfCharges"),
  greenTaxCharge("greenTaxCharge"),
  fovCharges("fovCharges"),
  gstCharges("gstCharges"),
  otherCharges("otherCharges"),
  remark("remark"),
  totalCharges("totalCharges");

  final String key;

  const ControllerKeys(this.key);
}
