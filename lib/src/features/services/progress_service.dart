import 'package:cloud_firestore/cloud_firestore.dart';

class ProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<int> getCompletedLessons(String userId) async {
    // Get the user progress document reference
    DocumentReference userProgressDoc = _firestore.collection('userProgress').doc(userId);

    DocumentSnapshot snapshot = await userProgressDoc.get();

    if (snapshot.exists) {
      // Cast the data to Map<String, dynamic>
      Map<String, dynamic> userprogressData = snapshot.data() as Map<String, dynamic>;

      // Accessing the completed lessons count
      return userprogressData['completedLessons'] ?? 0; // Return completed lessons count
    } else {
      print('User progress document does not exist.');
      return 0; // Return 0 or handle accordingly if document does not exist
    }
  }
}
