import 'package:flutter/material.dart';
import 'package:my_web/view/widgets/custom_button.dart';
import 'package:my_web/view/widgets/custom_test_field.dart';

class LoginDialog extends StatefulWidget {
  final Function(String name, String password) onLogin;

  const LoginDialog({super.key, required this.onLogin});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Login / Register'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'Your Name',
              hintText: 'Enter your name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _passwordController,
              labelText: 'Password',
              hintText: 'Enter a password (for new users) or your existing password',
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a password';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        CustomButton(
          text: 'Submit',
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              widget.onLogin(_nameController.text, _passwordController.text);
            }
          },
        ),
      ],
    );
  }
}

