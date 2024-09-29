import 'package:cloud_firestore/cloud_firestore.dart';

class LessonProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getCompletedLessons(String userId) async {
    DocumentReference userLessonProgressDoc = _firestore.collection('userLessonProgress').doc(userId);

    DocumentSnapshot snapshot = await userLessonProgressDoc.get();

    if (snapshot.exists) {
      Map<String, dynamic> userLessonProgressData = snapshot.data() as Map<String, dynamic>;
      return userLessonProgressData['completedLessons'] ?? 0;
    } else {
      print('User LessonProgress document does not exist.');
      return 0; 
    }
  }
}