import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../common/enums/user_roles_enum.dart';

class AddUserScreen extends StatefulWidget {

  final String? name, email, password, designation;
  final UserRolesEnum rolesEnum;

  const AddUserScreen({
    super.key,
    this.name,
    this.email,
    this.password,
    this.designation,
    this.rolesEnum = UserRolesEnum.user,
  });

  @override
  State<AddUserScreen> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserScreen> {

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _designationController;
  late UserRolesEnum _selectedRole;

  @override
  void initState() {
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
    _passwordController = TextEditingController(text: widget.password);
    _designationController = TextEditingController(text: widget.designation);
    _selectedRole = widget.rolesEnum;

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  void _submit() {

    if (_validateEmail(_emailController.text) != null)  {
      Fluttertoast.showToast(
        msg: "Invalid Email/Value added",
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      Navigator.pop(
        context,
        {
          "name" : _nameController.text,
          "email" : _emailController.text,
          "pass" : _passwordController.text,
          "designation" : _designationController.text,
          "role" : _selectedRole.id,
        }
      );
    }
  }

  String? _validateEmail(String? val) {
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regex = RegExp(pattern);

    if (val == null || val.isEmpty) return 'Email is required';
    if (!regex.hasMatch(val)) return 'Enter a valid email address';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(
          _nameController.text.isEmpty ? l10n.enterDetails : l10n.editDetails,
          style: const TextStyle(fontWeight: FontWeight.bold),
        )),
        body: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // name field
                  _buildTextField(_nameController, l10n.name),
                  const SizedBox(height: 10),

                  // email field
                  _buildTextField(
                    _emailController,
                    l10n.email,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) => _validateEmail(val),
                  ),
                  const SizedBox(height: 10),

                  // password field
                  _buildTextField(
                    _passwordController,
                    l10n.password,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.length < 4) {
                        return l10n.passwordLength;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 10),

                  // designation field
                  _buildTextField(_designationController, l10n.designation),
                  const SizedBox(height: 15),

                  // user selection field
                  DropdownButtonFormField<UserRolesEnum>(
                    value: _selectedRole,
                    decoration: InputDecoration(
                      labelText: l10n.selectRole,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      filled: true,
                      fillColor: Colors.grey[100],
                    ),
                    items: UserRolesEnum.values.map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role.name.toUpperCase()),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _selectedRole = value ?? _selectedRole);
                    },
                    validator: (value) => value == null ? l10n.pleaseSelectRole : null,
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
        bool obscureText = false,
        TextInputType keyboardType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    final l10n = AppLocalizations.of(context)!;
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) return l10n.fieldRequired(label);
        return null;
      },
    );
  }
}
