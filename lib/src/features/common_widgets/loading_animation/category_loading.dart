import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class LoadingShimmerCategory extends StatelessWidget {
  const LoadingShimmerCategory({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3, // Simulating 4 category placeholders
      itemBuilder: (context, index) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 15.0),
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          height: MediaQuery.of(context).size.height * 1 / 3.61,
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(width: 3, color: Color.fromARGB(255, 96, 96, 96)),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Category Title Shimmer
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 15.0),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: Container(
                    height: 25,
                    width: 150,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                ),
              ),

              // Subcategory Images Shimmer (Horizontal Scrolling)
              SizedBox(
                height: 130, // Height for subcategory images
                child: Shimmer.fromColors(
                  baseColor: Colors.grey.shade300,
                  highlightColor: Colors.grey.shade100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 3, // Simulating 3 subcategory placeholders
                    separatorBuilder: (context, _) => const SizedBox(width: 15),
                    itemBuilder: (context, index) {
                      return Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Subcategory Image Shimmer
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Subcategory Title Shimmer
                            Container(
                              width: 80,
                              height: 15,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
