import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/appbar.dart';
import 'package:taga_cuyo/src/features/common_widgets/bottom_navigation.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/home/explore_page.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/profile/profile_screen.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/translator/translator_screen.dart';




class HomeScreen extends StatefulWidget {
  final String uid; // Accept uid as a parameter

  const HomeScreen({
    super.key,
    required this.uid,
    required Map<String, dynamic> userData,
  });

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of pages/icons that correspond to each tab in the bottom navigation bar
  static final List<Widget> _widgetOptions = <Widget>[
    const ExplorePage(),
    const Text('Lesson Page'),
    const Text('Category Page'),
    TranslatorScreen(),
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
