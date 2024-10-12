import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

Widget lessonShimmerLoading() {
  return Shimmer.fromColors(
    baseColor: Colors.grey[300]!,
    highlightColor: Colors.grey[100]!,
    child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,  // Number of columns in the grid
        crossAxisSpacing: 10, // Horizontal spacing between items
        mainAxisSpacing: 10,  // Vertical spacing between items
      ),
      itemCount: 6,  // Number of shimmer loading items to show
      itemBuilder: (context, index) {
        return Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Container(
              color: Colors.white,
              height: 60,
              width: 80,
            ),
          ),
        );
      },
    ),
  );
}
