import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating, // Make the Snackbar float
      margin: const EdgeInsets.all(16.0), // Adjust the margin as needed
      duration: const Duration(
          seconds:
              2), // Duration for which the Snackbar is visible  // Use 'content' instead of 'context'
    ),
  );
}
