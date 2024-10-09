import 'package:flutter/material.dart';

Future<void> showCustomAlertDialog(
  BuildContext context,
  String title,
  String content, {
  String buttonText = 'OK', // Default value for the button text
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(buttonText), // Use the provided button text
          ),
        ],
      );
    },
  );
}
