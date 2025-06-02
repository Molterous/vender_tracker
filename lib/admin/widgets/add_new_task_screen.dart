import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vender_tracker/common/models/user.dart';

class AddTaskScreen extends StatefulWidget {

  final List<User> users;
  final User? worker;
  final String? dueDate, title, desc;
  final Map<String, dynamic> updates;

  const AddTaskScreen({
    super.key,
    required this.users,
    this.worker,
    this.dueDate,
    this.title,
    this.desc,
    this.updates = const {},
  });

  @override
  State<AddTaskScreen> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  DateTime? _selectedDueDate;
  User? _selectedUser;

  @override
  void initState() {
    _titleController = TextEditingController(text: widget.title);
    _descController = TextEditingController(text: widget.desc);
    _selectedUser = widget.worker;

    if (widget.dueDate != null) {
      _selectedDueDate = DateTime.parse(widget.dueDate!);
    }

    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      currentDate: _selectedDueDate,
    );
    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate() &&
        _selectedDueDate != null &&
        _selectedUser != null) {

      final newDate = _selectedDueDate.toString();

      if (_selectedUser!.userId != (widget.worker?.userId ?? _selectedUser!.userId)) {

        widget.updates.addAll({
          "moved from \n${widget.worker!.name} (${widget.worker!.userId}) to "
              "${_selectedUser!.name} (${_selectedUser!.userId})" : DateTime.now().toString(),
        });

      }

      if (newDate != (widget.dueDate ?? newDate)) {

        widget.updates.addAll(<String, String>{
          "due date moved from \n${widget.dueDate!.split(" ").first} to "
              "${newDate.split(" ").first}" : DateTime.now().toString(),
        });

      }

      Navigator.pop(
          context,
          {
            "title"   : _titleController.text,
            "desc"    : _descController.text,
            "dueDate" : newDate,
            "userId"  : _selectedUser!.userId,
            "updates" : widget.updates,
          }
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(
          widget.title == null ? l10n.createNewTask : l10n.updateTask,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // title
                  _buildTextField(
                    _titleController,
                    l10n.title,
                    maxLines: 2,
                    enabled: (widget.title ?? '').isEmpty
                  ),
                  const SizedBox(height: 10),

                  // desc
                  _buildTextField(
                    _descController,
                    l10n.description,
                    maxLines: 6,
                    enabled: (widget.desc ?? '').isEmpty,
                  ),
                  const SizedBox(height: 10),

                  // date picker
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      _selectedDueDate == null
                          ? l10n.selectDueDate
                          : '${l10n.dueDate}: ${_selectedDueDate!.toLocal().toString().split(' ')[0]}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: _pickDueDate,
                    ),
                  ),
                  const SizedBox(height: 15),

                  // user selection drop down
                  DropdownButtonFormField<User>(
                    value: _selectedUser,
                    decoration: InputDecoration(
                      labelText: l10n.assignTo,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    items: widget.users.map((user) {
                      return DropdownMenuItem<User>(
                        value: user,
                        child: Text('${user.name} ${user.userId}'),
                      );
                    }).toList(),
                    onChanged: (value) => setState(() => _selectedUser = value),
                    validator: (value) => value == null ? l10n.pleaseSelectUser : null,
                  ),
                  const SizedBox(height: 15),

                  // save button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        int maxLines = 1,
        bool enabled = true,
      }) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
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
}
