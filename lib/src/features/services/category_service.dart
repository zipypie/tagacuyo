import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getCompletedCategories(String userId) async {
    DocumentReference userCategoryProgressDoc = _firestore.collection('userCategoryProgress').doc(userId);

    DocumentSnapshot snapshot = await userCategoryProgressDoc.get();

    if (snapshot.exists) {
      Map<String, dynamic> userCategoryProgressData = snapshot.data() as Map<String, dynamic>;
      return userCategoryProgressData['completedCategories'] ?? 0;
    } else {
      print('User CategoryProgress document does not exist.');
      return 0; 
    }
  }

  Future<void> incrementCompletedCategories(String userId) async {
    DocumentReference userCategoryProgressDoc = _firestore.collection('userCategoryProgress').doc(userId);

    await userCategoryProgressDoc.set({
      'completedCategories': FieldValue.increment(1),
    }, SetOptions(merge: true)); // Use merge to update the document without overwriting existing data
  }
}
