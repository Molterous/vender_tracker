import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:vender_tracker/admin/views/admin_panel.dart';
import 'package:vender_tracker/common/enums/page_status.dart';
import 'package:vender_tracker/common/enums/user_roles_enum.dart';
import 'package:vender_tracker/login/cubit/login_cubit.dart';
import 'package:vender_tracker/login/cubit/login_state.dart';

import '../../users/views/user_panel.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit()..loginInit(),
      child: BlocListener<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state.pageStatus.isSuccess && state.activeUser != null) {
            if (state.activeUser!.role == UserRolesEnum.user) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UserPanel()),
              );
            } else {

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AdminPanel()),
              );
            }
          }
        },
        child: const _LoginScreen(),
      ),
    );
  }
}


class _LoginScreen extends StatefulWidget {
  const _LoginScreen();

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  void _submit() {

    if (_validateEmail(_emailController.text) != null) { return; }

    if (_formKey.currentState!.validate()) {
      context.read<LoginCubit>().loginUser(
        _emailController.text,
        _passwordController.text,
      );
    }
  }

  String? _validateEmail(String? val) {
    const pattern = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
    final regex = RegExp(pattern);
    final l10n = AppLocalizations.of(context)!;

    if (val == null || val.isEmpty) return l10n.emailRequired;
    if (!regex.hasMatch(val)) return l10n.enterValidEmail;
    return null;
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label, {
        bool obscure = false,
        TextInputType inputType = TextInputType.text,
        String? Function(String?)? validator,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      obscureText: obscure,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[100],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Icon(Icons.lock_outline, size: 100, color: Colors.black),
                  const SizedBox(height: 40),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          _emailController,
                          l10n.email,
                          inputType: TextInputType.emailAddress,
                          validator: (val) => _validateEmail(val),
                        ),
                        const SizedBox(height: 20),
                        _buildTextField(
                          _passwordController,
                          l10n.password,
                          obscure: true,
                          validator: (val) {
                            if (val == null || val.length < 4) return l10n.passwordLength;
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        BlocBuilder<LoginCubit, LoginState>(
                          buildWhen: (prev, curr) => prev.errorMessage != curr.errorMessage,
                          builder: (context, state) {
                            if (state.errorMessage.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  state.errorMessage,
                                  style: const TextStyle(color: Colors.red),
                                ),
                              );
                            }

                            return const SizedBox();
                          },
                        ),

                        BlocBuilder<LoginCubit, LoginState>(
                          buildWhen: (prev, curr) => prev.pageStatus != curr.pageStatus,
                          builder: (context, state) {

                            return SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: state.pageStatus.isLoading ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: state.pageStatus.isLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                        'Login',
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                              ),
                            );

                          },
                        ),
                      ],
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
}
