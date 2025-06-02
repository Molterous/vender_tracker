import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vender_tracker/common/enums/user_roles_enum.dart';
import 'package:vender_tracker/common/models/pair.dart';
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
  final List<Pair<TextEditingController, TextEditingController>>
      _itemsController = [];

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

    widget.quotation?.services.forEach((key, value) {
      _itemsController.add(Pair(TextEditingController(text: key),
          TextEditingController(text: value)));
    });

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    _noteController.dispose();

    for (var ele in _itemsController) {
      ele.first.dispose();
      ele.second.dispose();
    }

    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate() && _selectedTask != null) {
      final itemMap = <String, String>{};

      for (var i in _itemsController) {
        itemMap[i.first.text] = i.second.text;
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
          services: itemMap,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    final width = MediaQuery.of(context).size.width;
    final l10n = AppLocalizations.of(context)!;
    final isAdmin = globalActiveUser!.role == UserRolesEnum.admin;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.quotation == null ? l10n.createQuotation : l10n.updateQuotation,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: !isAdmin
            ? null
            : [
                Container(
                  margin: const EdgeInsets.only(right: 20),
                  child: InkWell(
                    onTap: () {
                      if (_itemsController.isEmpty) {

                        return;
                      }


                      List<String> header = [];
                      header.add('S.No.');
                      header.add('Service');
                      header.add('Cost');

                      List<List<String>> listOfLists = [];

                      for (var i=0; i<_itemsController.length; i++) {

                        final item = _itemsController[i];
                        List<String> data = ['${i+1}', item.first.text, item.second.text];
                        listOfLists.add(data);
                      }

                      exportCSV.myCSV(header, listOfLists);
                    },
                    child: Icon(Icons.share),
                  ),
                ),
              ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
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
                  maxLines: 6,
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
                      _itemsController.add(Pair(
                          TextEditingController(), TextEditingController()));
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

        return Container(
          margin: const EdgeInsets.symmetric(vertical: 5),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // service name
                Expanded(
                  flex: 3,
                  child: _buildTextField(
                    item.first,
                    l10n.service,
                    maxLines: 2,
                  ),
                ),
                const SizedBox(width: 10),

                // service value
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    item.second,
                    l10n.cost,
                    maxLines: 2,
                    isNumKeys: true,
                  ),
                ),
                const SizedBox(width: 10),

                // remove tile btn
                if (isAdmin)
                  InkWell(
                    onTap: () =>
                        setState(() => _itemsController.removeAt(index)),
                    child: const Icon(Icons.delete),
                  )
              ],
            ),
          ),
        );
      },
    );
  }
}
