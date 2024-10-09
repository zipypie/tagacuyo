import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';

class CategoryProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Update the user progress for a specific category and subcategory
Future<void> updateUserProgress({
  required String userId,
  required String categoryId,
  required String subcategoryId,
}) async {
  try {
    // Reference to the user's progress document
    DocumentReference userProgressRef =
        _firestore.collection('user_progress').doc(userId);

    // Get the current user progress data
    DocumentSnapshot progressSnapshot = await userProgressRef.get();

    bool isCompleted = false;
    Map<String, dynamic>? progressData; // Define progressData here

    // Check if the document exists and the subcategory is already marked as completed
    if (progressSnapshot.exists) {
      progressData = progressSnapshot.data() as Map<String, dynamic>?;

      if (progressData != null &&
          progressData.containsKey('categories_progress') &&
          progressData['categories_progress'].containsKey(categoryId) &&
          progressData['categories_progress'][categoryId]
              .containsKey(subcategoryId)) {
        isCompleted = progressData['categories_progress'][categoryId]
                [subcategoryId]['isCompleted'] ??
            false;
      }
    }

    // If already completed, no need to update
    if (isCompleted) {
      return;
    }

    // Proceed to update only if not completed
    await userProgressRef.set({
      'categories_progress': {
        categoryId: {
          subcategoryId: {'isCompleted': true},
        },
      },
    }, SetOptions(merge: true));

    // Increment the count of completed categories
    if (progressSnapshot.exists) {
      // Get current count of completed categories
      int completedCount = progressData?['categories'] ?? 0;

      // Update the completed count
      await userProgressRef.set({
        'categories': completedCount + 1,
      }, SetOptions(merge: true));
    } else {
      // If the document doesn't exist, create it with the count set to 1
      await userProgressRef.set({
        'categories': 1,
        'categories_progress': {
          categoryId: {
            subcategoryId: {'isCompleted': true},
          },
        },
      }, SetOptions(merge: true));
    }
  } catch (e) {
    Logger.log('Error updating user progress: $e');
  }
}


  /// Check if a specific subcategory is finished for a user
  Future<bool> isSubcategoryFinished({
    required String userId,
    required String categoryId,
    required String subcategoryId,
  }) async {
    try {
      // Reference to the user's progress document
      DocumentReference userProgressRef =
          _firestore.collection('user_progress').doc(userId);

      // Get the current user progress data
      DocumentSnapshot progressSnapshot = await userProgressRef.get();

      // Check if the document exists and retrieve completion status
      if (progressSnapshot.exists) {
        Map<String, dynamic>? progressData =
            progressSnapshot.data() as Map<String, dynamic>?;

        if (progressData != null &&
            progressData.containsKey('categories_progress') &&
            progressData['categories_progress'].containsKey(categoryId) &&
            progressData['categories_progress'][categoryId]
                .containsKey(subcategoryId)) {
          return progressData['categories_progress'][categoryId]
                  [subcategoryId]['isCompleted'] ??
              false;
        }
      }

      // Return false if the subcategory has not been completed
      return false;
    } catch (e) {
      Logger.log('Error checking if subcategory is finished: $e');
      return false;
    }
  }

  Future<void> getUpdatedProgress({
    required String userId,
    required String categoryId,
    required String subcategoryId,
  }) async {
    DocumentReference userProgressRef =
        _firestore.collection('user_progress').doc(userId);

    DocumentSnapshot progressSnapshot = await userProgressRef.get();

    if (progressSnapshot.exists) {
      Map<String, dynamic>? progressData =
          progressSnapshot.data() as Map<String, dynamic>?;

      if (progressData != null &&
          progressData.containsKey('categories_progress') &&
          progressData['categories_progress'].containsKey(categoryId) &&
          progressData['categories_progress'][categoryId]
              .containsKey(subcategoryId)) {
        bool isCompleted = progressData['categories_progress'][categoryId]
            [subcategoryId]['isCompleted'];
        Logger.log('Subcategory $subcategoryId completion status: $isCompleted');
      }
    } else {
      Logger.log('User progress document does not exist.');
    }
  }

  /// Retrieve the list of completed subcategories for a given user and category
  Future<List<String>> getCompletedSubcategories({
    required String userId,
    required String categoryId,
  }) async {
    try {
      // Reference to the user's progress document
      DocumentReference userProgressRef =
          _firestore.collection('user_progress').doc(userId);

      // Get the current user progress data
      DocumentSnapshot progressSnapshot = await userProgressRef.get();

      if (progressSnapshot.exists) {
        Map<String, dynamic>? progressData =
            progressSnapshot.data() as Map<String, dynamic>?;

        if (progressData != null &&
            progressData.containsKey('categories_progress')) {
          Map<String, dynamic> categoriesProgress =
              progressData['categories_progress'] as Map<String, dynamic>;

          if (categoriesProgress.containsKey(categoryId)) {
            Map<String, dynamic> subcategories =
                categoriesProgress[categoryId] as Map<String, dynamic>;

            return subcategories.entries
                .where((entry) => entry.value['isCompleted'] == true)
                .map((entry) => entry.key)
                .toList();
          }
        }
      }

      return [];
    } catch (e) {
      Logger.log('Error retrieving completed subcategories: $e');
      return [];
    }
  }
}
