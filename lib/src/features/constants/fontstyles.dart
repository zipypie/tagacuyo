
import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';


class AppFonts {
  static const String lilitaOne = 'LilitaOne';  // Must match the family name in pubspec.yaml
  static const String kanitLight = 'Kanit';  // Must match the family name in pubspec.yaml
  static const String roboto = 'Roboto-Regular';  // Must match the family name in pubspec.yaml

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
  static const TextStyle subtitle = TextStyle(
    fontFamily: AppFonts.roboto,
    fontSize: 21,
    fontWeight: FontWeight.w900,
    color: Color.fromARGB(255, 0, 0, 0),
  );

  // Body text style
  static const TextStyle body = TextStyle(
    fontFamily: AppFonts.kanitLight,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.titleColor, // You can adjust the color as needed
  );

  // Button text style
  static const TextStyle buttonl = TextStyle(
    fontFamily: AppFonts.kanitLight,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.primaryBackground, // Use accent color for buttons
  );

   static const TextStyle buttond = TextStyle(
    fontFamily: AppFonts.kanitLight,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.titleColor, // Use accent color for buttons
  );

  // Caption style
  static const TextStyle caption = TextStyle(
    fontFamily: AppFonts.kanitLight,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: Color.fromARGB(255, 91, 91, 91), // Light grey color for captions or secondary info
  );

    static const TextStyle learningtitle = TextStyle(
    fontFamily: AppFonts.kanitLight,
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: AppColors.titleColor, // Light grey color for captions or secondary info
  );
}
