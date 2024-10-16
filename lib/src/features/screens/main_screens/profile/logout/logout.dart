import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for managing local storage
import 'package:taga_cuyo/src/features/common_widgets/custom_alert_dialog.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart'; // Import your custom colors
import 'package:taga_cuyo/src/features/constants/fontstyles.dart'; // Import your custom font styles
import 'package:taga_cuyo/src/features/screens/onboarding_screens/login/login.dart'; // Import LoginScreen

class LogoutScreen extends StatelessWidget {
  const LogoutScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      // Close the logout confirmation dialog
      Navigator.of(context).pop();

      // Firebase sign out
      await FirebaseAuth.instance.signOut();

      // Clear saved data from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear(); // Clear all saved data

      // Navigate to the LoginScreen after logging out
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) =>
                const SignInScreen()), // Navigate to LoginScreen
        (route) => false, // Remove all previous routes
      );
    } catch (e) {
      // Show an error message if logout fails
      showCustomAlertDialog(
          context, 'Error', e.toString()); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12), // Rounded corners
      ),
      elevation: 10, // Shadow effect
      child: Container(
        padding: const EdgeInsets.all(20), // Padding inside the dialog
        decoration: BoxDecoration(
          color:
              AppColors.secondaryBackground, // Background color of the dialog
          borderRadius:
              BorderRadius.circular(12), // Match the shape's border radius
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Size the dialog to fit its content
          children: [
            const Text(
              "Log Out",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                fontFamily: AppFonts.fcb, // Set the font family for the title
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Sigurado ka bang gusto mong mag-log out?",
              style: TextStyle(
                fontSize: 21,
                fontFamily: AppFonts.fcr, // Set the font family for the content
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Space the buttons evenly
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors
                        .titleColor, // Set the text color on the button
                    backgroundColor: AppColors
                        .primaryBackground, // Set the button's background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          25), // Rounded corners for button
                    ),
                  ),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: AppFonts
                          .fcb, // Set the font family for the button text
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        Colors.white, // Set the text color on the button
                    backgroundColor:
                        AppColors.primary, // Set the button's background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                          25), // Rounded corners for button
                    ),
                  ),
                  child: const Text(
                    "Log Out",
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: AppFonts
                          .fcb, // Set the font family for the button text
                    ),
                  ),
                  onPressed: () async {
                    await _logout(context); // Perform logout and clear data
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
