import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/services/auth_wrapper.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(MyApp());
}

// Initialize content of the app
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Taga-Cuyo App',
      debugShowCheckedModeBanner: false,
      home: AuthWrapper(),
    );
  }
}
