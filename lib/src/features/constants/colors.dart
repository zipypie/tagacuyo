import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryBackground = Color(0xFFFFFFFF); // FFFFFF
  static const Color secondaryBackground = Color(0xFFFDF2C2); // FFF2C2
  static const Color titleColor = Color(0xFF263238); // 263238
  static const Color secondary = Color(0xFFE0F7FA); // E0F7FA
  static const Color primary = Color(0xFFFFD54F); // FFD54F
  static const Color lightGrey = Color(0xFFD9D9D9); // D9D9D9
  static const Color subtitleColor = Color(0xFF676767); // 676767
  static const Color correct = Color(0xFF69F177); // 69F177
  static const Color wrong = Color(0xFFF90909); // F90909
  
  static LinearGradient boxGradient = const LinearGradient(
    colors: [
      Color(0xFF4FC3F7), // 4FC3F7
      Color(0xFF2BA7B6), // 2BA7B6     
   
    ],
    stops: [0.0, 0.9],
  );
}
