import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  final String src;
  final double width;
  final double height;

  const CustomImage({
    super.key,
    required this.src,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      src,
      width: width,
      height: height,
      fit: BoxFit.cover, // You can change this to BoxFit.contain or any other option if needed
    );
  }
}
