import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

class AppBarScreen extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AppBarScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false, // This removes the back button
      toolbarHeight: 70, // Set the height of the AppBar
      title: Padding(
        padding: const EdgeInsets.only(left: 20), // Padding for the title
        child: Text(
          title,
          style: const TextStyle(color: AppColors.titleColor,fontFamily: AppFonts.lilitaOne,fontSize: 24),
        ),
      ),
      actions: <Widget>[
       Padding(
         padding: const EdgeInsets.only(right: 20),
         child: Container(
           width: 60,
           height: 60,
           decoration: BoxDecoration(
             borderRadius: BorderRadius.circular(25),
           ),
           child: Align(
             alignment: Alignment.centerRight,
             child: ClipOval(
               child: Image.asset(
          'assets/images/tagacuyo_logo.png', 
          fit: BoxFit.cover, // This works without issues
               ),
             ),
           ),
         ),
       ),


      ],
      backgroundColor: AppColors.primary, // Customize AppBar color
    );
  }

  // Implement preferredSize
  @override
  Size get preferredSize => const Size.fromHeight(70); // Specify the AppBar's height
}
