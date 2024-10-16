import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';

class ProfileLoadingShimmer extends StatelessWidget {
  const ProfileLoadingShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section (Shimmer Effect)
            Container(
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.primaryBackground,
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Row(
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 20,
                              width: 150,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: Container(
                              height: 15,
                              width: 100,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Progress Section (Shimmer Effect)
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.fromLTRB(30, 30, 30, 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      height: 20,
                      width: 120,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 20,
                    runSpacing: 15,
                    children: [
                      _buildProgressItemShimmer(),
                      _buildProgressItemShimmer(),
                      _buildProgressItemShimmer(),
                      _buildProgressItemShimmer(),
                      _buildProgressItemShimmer(),
                      _buildProgressItemShimmer(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressItemShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: 150,
        height: 60,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
