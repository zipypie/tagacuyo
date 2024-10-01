
import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';


class AppFonts {
  static const String lilitaOne = 'LilitaOne';  // Must match the family name in pubspec.yaml
  static const String kanitLight = 'Kanit';  // Must match the family name in pubspec.yaml
  static const String roboto = 'Roboto-Regular';  // Must match the family name in pubspec.yaml
  static const String feb = 'FEB';
  static const String fer = 'FER';
  static const String fcb = 'FCB';
  static const String fcr = 'FCR';

}



class TextStyles {
  // Title style with font size 24
  static const TextStyle title = TextStyle(
    fontFamily: AppFonts.lilitaOne, // You can change this to your preferred font like 'Poppins', 'Lato', etc.
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.titleColor, // Make sure this is defined in your AppColors
  );

  // Subtitle style
  static const TextStyle learningtitle = TextStyle(
    fontFamily: AppFonts.fcb,
    fontSize: 20,
    fontWeight: FontWeight.w900,
    color: Color.fromARGB(255, 60, 63, 65),
  );
      static const TextStyle learningsubtitle = TextStyle(
    fontFamily: AppFonts.fcr,
    fontSize: 14,
    color: Color.fromARGB(255, 0, 0, 0), // Light grey color for captions or secondary info
  );

        static const TextStyle sublearningsubtitle = TextStyle(
    fontFamily: AppFonts.feb,
    fontSize: 16,
    color: Color.fromARGB(255, 113, 113, 113), // Light grey color for captions or secondary info
  );




}
