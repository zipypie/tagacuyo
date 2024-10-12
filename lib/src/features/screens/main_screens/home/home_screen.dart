// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/appbar.dart';
import 'package:taga_cuyo/src/features/common_widgets/bottom_navigation.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/category/category_screen.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/home/explore_page.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/lesson/lesson_screen.dart';
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

  // Create a PageController to control the PageView
  final PageController _pageController = PageController(
    initialPage: 0, 
    viewportFraction: 1.0, // Keeps the pages fully visible for smoother transitions
  );

  // List of pages/icons that correspond to each tab in the bottom navigation bar
  static final List<Widget> _widgetOptions = <Widget>[
    const ExplorePage(),
    TranslatorScreen(),
    const LessonScreenPage(),
    const CategoryScreen(),
  ];

  // List of titles corresponding to each page
  static final List<String> _titles = <String>[
    'Home',
    'Tagasalin',
    'Aralin',
    'Kategorya',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    // Add ProfileScreenPage with the actual UID
    final List<Widget> pagesWithProfile = List.from(_widgetOptions)
      ..add(ProfileScreen(uid: widget.uid)); // Add ProfileScreenPage

    // Function to handle tab change
    void onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
      // Animate the page change with a different curve (fastOutSlowIn)
      _pageController.animateToPage(index, 
        duration: const Duration(milliseconds: 450), // Adjust for smoothness
        curve: Curves.fastOutSlowIn, // Use fastOutSlowIn for a more natural feel
      );
    }

    return Scaffold(
      appBar: AppBarScreen(title: _titles[_selectedIndex]), // Pass the title based on the selected index
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        physics: const NeverScrollableScrollPhysics(), // Disable swipe gestures
        children: pagesWithProfile,
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        onItemTapped: onItemTapped,
        selectedIndex: _selectedIndex,
      ),
    );
  }
}
