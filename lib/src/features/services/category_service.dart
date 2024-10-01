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
}
