import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/screens/settings/logout.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Account Settings Option
        ListTile(
          leading: const Icon(Icons.account_circle, color: Colors.teal),
          title: const Text(
            'Setting ng account',
            style: TextStyle(
              fontFamily: AppFonts.kanitLight,
              fontSize: 16,
            ),
          ),
          onTap: () {
            // Handle account settings tap
          },
        ),

        // Feedback Option
        ListTile(
          leading: const Icon(Icons.feedback, color: Colors.teal),
          title: const Text(
            'Katugunan',
            style: TextStyle(
              fontFamily: AppFonts.kanitLight,
              fontSize: 16,
            ),
          ),
          onTap: () {
            // Handle feedback tap
          },
        ),

        // Logout Option with Icon
        ListTile(
          leading: const Icon(Icons.logout, color: Colors.red),
          title: const Text(
            'Logout',
            style: TextStyle(
              fontFamily: AppFonts.kanitLight,
              fontSize: 16,
            ),
          ),
          onTap: () {
            // Show the logout confirmation dialog
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const LogoutScreen(); // Show the logout confirmation
              },
            );
          },
        ),
      ],
    );
  }
}
