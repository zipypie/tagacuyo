import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taga_cuyo/src/features/screens/onboarding_screens/get_started/get_started.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/home/home_screen.dart';


class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    // Check if the user is logged in
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          // If user is logged in, show HomeScreen; otherwise, show GetStartedScreen
          return snapshot.hasData
              ? HomeScreen(uid: snapshot.data!.uid, userData: const {})
              : const GetStartedScreen();
        }
        // Show a loading indicator while waiting for authentication state
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
