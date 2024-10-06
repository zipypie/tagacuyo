import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';

class CategoryProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retrieves the completed subcategories for a specific user and category.
  Future<Map<String, dynamic>> getSubcategories(String userId, String categoryTitle) async {
    DocumentReference categoryDocRef = _firestore
        .collection('user_progress')
        .doc(userId)
        .collection('categories_progress')
        .doc(categoryTitle);

    DocumentSnapshot snapshot = await categoryDocRef.get();

    if (snapshot.exists) {
      Map<String, dynamic> categoryData = snapshot.data() as Map<String, dynamic>;
      return categoryData['subcategories'] ?? {}; // Return subcategories map
    } else {
      Logger.log('Category document does not exist for user $userId and category $categoryTitle.');
      return {}; // Return an empty map if the document does not exist
    }
  }

  /// Creates a new category progress entry for the user.
  Future<void> createCategoryProgress(String userId, String categoryTitle) async {
    try {
      await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('categories_progress')
          .doc(categoryTitle)
          .set({
        'subcategories': {}, // Initialize an empty map for subcategories
      }, SetOptions(merge: true)); // Use merge to ensure data isn't overwritten
      Logger.log('Category progress created for $categoryTitle');
    } catch (e) {
      Logger.log('Error creating category progress: $e');
    }
  }

  /// Marks a subcategory as completed inside a specific category.
  Future<void> markSubcategoryAsCompleted(String userId, String categoryId, String subcategoryId) async {
    try {
      // Retrieve the document for the category
      DocumentSnapshot categoryDoc = await _firestore
          .collection('user_progress')
          .doc(userId)
          .collection('categories_progress')
          .doc(categoryId)
          .get();

      if (categoryDoc.exists) {
        // Get the existing subcategories or initialize it as an empty map
        Map<String, dynamic> categoryData = categoryDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> subcategories = categoryData['subcategories'] ?? {};

        // Check if the subcategory exists and contains quizzes
        if (subcategories.containsKey(subcategoryId)) {
          // Ensure the subcategory has quizzes
          if (subcategories[subcategoryId]['quizzes'] != null && (subcategories[subcategoryId]['quizzes'] as List).isNotEmpty) {
            // Check if the subcategory is already marked as completed
            if (subcategories[subcategoryId]['isCompleted'] != true) {
              // Mark the specific subcategory as completed
              subcategories[subcategoryId]['isCompleted'] = true;

              // Update Firestore with the modified subcategories map
              await _firestore
                  .collection('user_progress')
                  .doc(userId)
                  .collection('categories_progress')
                  .doc(categoryId)
                  .set({
                'subcategories': subcategories // Set the updated map
              }, SetOptions(merge: true)); // Use merge to avoid overwriting other subcategories

              Logger.log("Subcategory $subcategoryId marked as completed successfully.");

              // Optional: Increment completed categories if all are completed
              bool allSubcategoriesCompleted = subcategories.values.every((v) => v['isCompleted'] == true);
              if (allSubcategoriesCompleted) {
                await incrementCompletedCategories(userId);
                Logger.log("All subcategories completed for category $categoryId. Incrementing completed categories.");
              }
            } else {
              Logger.log("Subcategory $subcategoryId was already marked as completed.");
            }
          } else {
            Logger.log("Subcategory $subcategoryId has no quizzes to complete.");
          }
        } else {
          Logger.log("Subcategory $subcategoryId does not exist in category $categoryId.");
        }
      } else {
        Logger.log("Category document does not exist for user $userId and category $categoryId.");
      }
    } catch (e) {
      Logger.log("Error marking subcategory as completed: $e");
    }
  }

  /// Increments the count of completed categories for the specified user.
  Future<void> incrementCompletedCategories(String userId) async {
    try {
      await _firestore.collection('user_progress').doc(userId).update({
        'categories': FieldValue.increment(1),
      });
      Logger.log('Completed categories incremented for user $userId');
    } catch (e) {
      Logger.log("Error incrementing completed categories: $e");
    }
  }
}
