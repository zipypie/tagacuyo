import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import for managing local storage
import 'package:taga_cuyo/src/features/screens/onboarding_screens/login/login.dart';
// Import LoginScreen

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
        MaterialPageRoute(builder: (context) => const SignInScreen()), // Navigate to LoginScreen
        (route) => false, // Remove all previous routes
      );
    } catch (e) {
      // Show an error message if logout fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error logging out: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Log Out"),
      content: const Text("Sigurado ka bang gusto mong mag-log out?"),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
        TextButton(
          child: const Text("Log Out"),
          onPressed: () async {
            await _logout(context); // Perform logout and clear data
          },
        ),
      ],
    );
  }
}
