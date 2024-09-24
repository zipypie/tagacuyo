import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';

class DropdownInputF extends StatelessWidget {
  final String? value;
  final List<String> items;
  final String hintText;
  final Function(String?)? onChanged;

  const DropdownInputF({
    super.key,
    this.value,
    required this.items,
    required this.hintText,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(5),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          color: Colors.white,
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            hint: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                hintText,
                style: const TextStyle(
                  color: Color.fromARGB(115, 58, 48, 48),
                  fontSize: 14,
                ),
              ),
            ),
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(item),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            style: const TextStyle(color: AppColors.titleColor), // Change text color if needed
            icon: const Padding(
              padding: EdgeInsets.only(right: 20),
              child: Icon(Icons.arrow_drop_down, color: Colors.black45),
            ),
          ),
        ),
      ),
    );
  }
}
