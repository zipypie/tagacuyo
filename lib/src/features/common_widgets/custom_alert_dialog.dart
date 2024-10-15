import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

Future<void> showCustomAlertDialog(
  BuildContext context,
  String title,
  String content, {
  String buttonText = 'OK', // Default value for the button text
}) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return Dialog( // Use Dialog for more customization
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12), // Rounded corners
        ),
        elevation: 10, // Shadow effect
        child: Container(
          padding: const EdgeInsets.all(20), // Padding inside the dialog
          decoration: BoxDecoration(
            color: AppColors.secondaryBackground, // Background color of the dialog
            borderRadius: BorderRadius.circular(12), // Match the shape's border radius
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Size the dialog to fit its content
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  fontFamily: AppFonts.fcb, // Set the font family for the title
                ),
              ),
              const SizedBox(height: 10),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 21,
                  fontFamily: AppFonts.fcr, // Set the font family for the content
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, // Set the text color on the button
                  backgroundColor: AppColors.primary, // Set the button's background color
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25), // Rounded corners for button
                  ),
                ),
                child: Text(
                  buttonText, // Use the provided button text
                  style: const TextStyle(
                    fontSize: 18,
                    fontFamily: AppFonts.fcb, // Set the font family for the button text
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
}
