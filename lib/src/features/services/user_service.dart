import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> getUserById(String userId) async {
    return await _firestore.collection('users').doc(userId).get();
  }

  Future<void> updateUserEmail(String userId, String newEmail) async {
    await _firestore.collection('users').doc(userId).update({'email': newEmail});
  }

  Future<List<DocumentSnapshot>> searchUsersByEmail(String email) async {
    return await _firestore.collection('users').where('email', isEqualTo: email).get().then((snapshot) => snapshot.docs);
  }
}
