import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/screens/settings/settings.dart';

void showSettingsDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 20, horizontal: 15),
        content: const SizedBox(
          width: double.maxFinite, // Ensure width adapts
          child: Column(
            mainAxisSize: MainAxisSize.min, // Minimize dialog height
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Settings',
                style: TextStyle(
                  fontFamily: AppFonts.kanitLight,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20), // Space between title and options
              SettingScreen(), // Embed the settings screen inside dialog
            ],
          ),
        ),
      );
    },
  );
}
