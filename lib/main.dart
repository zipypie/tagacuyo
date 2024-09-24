// ignore_for_file: prefer_final_fields, prefer_const_constructors

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/appbar.dart';
import 'package:taga_cuyo/src/features/common_widgets/bottom_navigation.dart';
import 'package:taga_cuyo/src/features/screens/get_started/get_started.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/home.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/translator.dart';

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

// Create an AuthWrapper widget to handle navigation
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
              ? HomeScreen(
                  uid: snapshot.data!.uid,
                  userData: const {},
                ) // Pass the actual UID
              : const GetStartedScreen();
        }
        // Show a loading indicator while waiting for authentication state
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}

// Create a HomeScreen widget
class HomeScreen extends StatefulWidget {
  final String uid; // Accept uid as a parameter

  const HomeScreen(
      {super.key, required this.uid, required Map<String, dynamic> userData});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of pages/icons that correspond to each tab in the bottom navigation bar
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreenPage(),
    Text('Lesson Page'),
    Text('Category Page'),
    TranslationScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Add ProfileScreenPage with the actual UID
    final List<Widget> pagesWithProfile = List.from(_widgetOptions)
      ..add(ProfileScreenPage(uid: widget.uid)); // Add ProfileScreenPage

    void onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    return Scaffold(
      appBar: const AppBarScreen(title: 'Home'),
      body: Stack(
        children: [
          pagesWithProfile.elementAt(_selectedIndex), // Use modified list
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: onItemTapped,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
