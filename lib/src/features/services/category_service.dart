import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/category/category.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';

const String categoriesCollection = 'categories';

class CategoryService {
  final AuthService _authService = AuthService();

  // Fetch current user ID
  Future<String?> fetchCurrentUserId() async {
    return _authService.getUserId();
  }

  // Fetch all categories from Firestore
  Future<List<Category>> fetchCategories() async {
    try {
      CollectionReference collection =
          FirebaseFirestore.instance.collection(categoriesCollection);
      QuerySnapshot querySnapshot = await collection.get();

      // Use Future.wait to fetch categories and subcategories concurrently
      List<Future<Category>> categoryFutures = querySnapshot.docs.map((doc) async {
        String id = doc.id;
        String imagePath = (doc.data() as Map<String, dynamic>?)?['image_path'] ?? '';
        String imageUrl = imagePath.isNotEmpty ? await fetchImageFromStorage(imagePath) : '';
        List<Subcategory> subcategories = await fetchSubcategories(id);

        Logger.log("Fetched category: $id with ${subcategories.length} subcategories");

        return Category(
          id: id,
          imagePath: imageUrl,
          subcategories: subcategories,
        );
      }).toList();

      return await Future.wait(categoryFutures);
    } catch (e) {
      Logger.log("Error fetching categories: $e");
      return [];
    }
  }

  // Fetch image URL from Firebase Storage
  Future<String> fetchImageFromStorage(String imagePath) async {
    try {
      if (imagePath.isEmpty) return ''; // Avoid unnecessary fetches
      Reference imageRef = FirebaseStorage.instance.refFromURL(imagePath);
      return await imageRef.getDownloadURL();
    } catch (e) {
      Logger.log("Error fetching image from storage: $e");
      return '';
    }
  }

  // Fetch subcategories for a given category
  Future<List<Subcategory>> fetchSubcategories(String categoryId) async {
    try {
      CollectionReference subcollection = FirebaseFirestore.instance
          .collection(categoriesCollection)
          .doc(categoryId)
          .collection('subcategories');
      QuerySnapshot subcollectionSnapshot = await subcollection.get();

      // Fetch subcategories concurrently
      List<Future<Subcategory>> subcategoryFutures = subcollectionSnapshot.docs.map((subDoc) async {
        String subcategoryId = subDoc.id;
        Map<String, dynamic> data = subDoc.data() as Map<String, dynamic>;

        String imagePath = (data['image_path'] ?? '');
        String imageUrl = imagePath.isNotEmpty ? await fetchImageFromStorage(imagePath) : '';
        String name = data['subcategory_name'] ?? '';
        List<String> words = List<String>.from(data['words'] ?? []);

        return Subcategory(
          id: subcategoryId,
          name: name,
          imagePath: imageUrl,
          words: words,
        );
      }).toList();

      return await Future.wait(subcategoryFutures);
    } catch (e) {
      Logger.log("Error fetching subcategories: $e");
      return [];
    }
  }

  // Fetch completed subcategories count for a category and user
  Future<int> getCompletedSubcategoriesCount(String userId, String categoryId) async {
    List<String> completedSubcategories = await getCompletedSubcategories(
      userId: userId,
      categoryId: categoryId,
    );
    return completedSubcategories.length;
  }

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  /// Update the user progress for a specific category and subcategory
  Future<void> updateUserProgress({
    required String userId,
    required String categoryId,
    required String subcategoryId,
  }) async {
    try {
      // Reference to the user's progress document
      DocumentReference userProgressRef = _firestore.collection('user_progress').doc(userId);

      // Use a transaction to update progress atomically
      await _firestore.runTransaction((transaction) async {
        DocumentSnapshot progressSnapshot = await transaction.get(userProgressRef);

        bool isCompleted = false;
        Map<String, dynamic>? progressData = progressSnapshot.data() as Map<String, dynamic>?;

        if (progressData != null &&
            progressData.containsKey('categories_progress') &&
            progressData['categories_progress'].containsKey(categoryId) &&
            progressData['categories_progress'][categoryId].containsKey(subcategoryId)) {
          isCompleted = progressData['categories_progress'][categoryId][subcategoryId]['isCompleted'] ?? false;
        }

        // If already completed, no need to update
        if (isCompleted) return;

        // Proceed to update only if not completed
        transaction.set(userProgressRef, {
          'categories_progress': {
            categoryId: {
              subcategoryId: {'isCompleted': true},
            },
          },
        }, SetOptions(merge: true));

        int completedCount = progressData?['categories'] ?? 0;
        transaction.set(userProgressRef, {'categories': completedCount + 1}, SetOptions(merge: true));
      });
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
      DocumentReference userProgressRef = _firestore.collection('user_progress').doc(userId);
      DocumentSnapshot progressSnapshot = await userProgressRef.get();

      if (progressSnapshot.exists) {
        Map<String, dynamic>? progressData = progressSnapshot.data() as Map<String, dynamic>?;

        if (progressData != null &&
            progressData.containsKey('categories_progress') &&
            progressData['categories_progress'].containsKey(categoryId) &&
            progressData['categories_progress'][categoryId].containsKey(subcategoryId)) {
          return progressData['categories_progress'][categoryId][subcategoryId]['isCompleted'] ?? false;
        }
      }

      return false;
    } catch (e) {
      Logger.log('Error checking if subcategory is finished: $e');
      return false;
    }
  }

  /// Retrieve the list of completed subcategories for a given user and category
  Future<List<String>> getCompletedSubcategories({
    required String userId,
    required String categoryId,
  }) async {
    try {
      DocumentReference userProgressRef = _firestore.collection('user_progress').doc(userId);
      DocumentSnapshot progressSnapshot = await userProgressRef.get();

      if (progressSnapshot.exists) {
        Map<String, dynamic>? progressData = progressSnapshot.data() as Map<String, dynamic>?;

        if (progressData != null &&
            progressData.containsKey('categories_progress') &&
            progressData['categories_progress'].containsKey(categoryId)) {
          Map<String, dynamic> subcategories = progressData['categories_progress'][categoryId] as Map<String, dynamic>;
          return subcategories.entries
              .where((entry) => entry.value['isCompleted'] == true)
              .map((entry) => entry.key)
              .toList();
        }
      }

      return [];
    } catch (e) {
      Logger.log('Error retrieving completed subcategories: $e');
      return [];
    }
  }
}
