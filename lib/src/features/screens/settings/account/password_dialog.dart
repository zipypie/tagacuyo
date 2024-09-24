import 'package:flutter/material.dart';

class PasswordDialog extends StatelessWidget {
  final Function(String) onUpdate;
  final TextEditingController _passwordController = TextEditingController();

  PasswordDialog({super.key, required this.onUpdate});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ilagay ang kasalukuyang password'),
      content: TextFormField(
        controller: _passwordController,
        obscureText: true,
        decoration: const InputDecoration(hintText: 'Password'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            onUpdate(_passwordController.text);
            Navigator.of(context).pop();
          },
          child: const Text('Isumite'),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Kanselahin'),
        ),
      ],
    );
  }
}
