import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';

class CustomBottomNavigationBar extends StatefulWidget {
  final Function(int) onItemTapped; // Callback to update the selected index
  final int selectedIndex; // Tracks the selected index

  const CustomBottomNavigationBar({
    super.key,
    required this.onItemTapped,
    required this.selectedIndex,
  });

  @override
  // ignore: library_private_types_in_public_api
  _CustomBottomNavigationBarState createState() =>
      _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: AppColors.primary,
      type: BottomNavigationBarType
          .fixed, // Required when having more than 3 items
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.translate),
          label: 'Tagasalin',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_lesson),
          label: 'Aralin',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.category),
          label: 'Kategorya',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      currentIndex: widget.selectedIndex, // Selected tab index
      selectedItemColor:
          AppColors.titleColor, // Color of the selected icon and label
      unselectedItemColor: const Color.fromARGB(
          255, 167, 149, 73), // Color of unselected icons and labels
      onTap: widget.onItemTapped, // Handles tap on the bottom navigation items
    );
  }
}
