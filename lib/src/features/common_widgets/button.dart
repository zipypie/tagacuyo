import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

class MyButton extends StatelessWidget {
  final VoidCallback onTab;
  final String text;

  const MyButton({super.key, required this.onTab, required this.text,});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap : onTab, 
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Container(
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: AppFonts.kanitLight,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.titleColor,
            ),
          ),
        ),
      ),
    );
  }
}
