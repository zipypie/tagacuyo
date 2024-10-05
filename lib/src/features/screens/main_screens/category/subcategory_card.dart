import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/category/category.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/category/quiz/category_quiz.dart';

class SubcategoryCard extends StatelessWidget {
  final Subcategory subcategory;
  final String userId;
  final Category category; // Updated to accept Category object

  const SubcategoryCard({
    super.key,
    required this.subcategory,
    required this.userId,
    required this.category, // Added parameter for Category
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CategoryQuizScreen(
              subcategoryTitle: subcategory.name,
              categoryId: category.id, // Use the category's id
              userId: userId, currentWord: '',
            ),
          ),
        );
      },
      child: SizedBox(
        width: MediaQuery.of(context).size.width / 3,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(width: 6, color: AppColors.accentColor),
                borderRadius: BorderRadius.circular(20),
              ),
              width: 120,
              height: 120,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  subcategory.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(child: Text('Image not available'));
                  },
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subcategory.name,
              style: const TextStyle(
                fontFamily: AppFonts.fcr,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
