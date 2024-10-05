import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentSnapshot?> getUserById(String userId) async {
    try {
      DocumentSnapshot document = await _firestore.collection('users').doc(userId).get();
      return document.exists ? document : null;
    } catch (e) {
      Logger.log('Error fetching user by ID: $e');
      return null;
    }
  }

  Future<void> updateUserEmail(String userId, String newEmail) async {
    try {
      await _firestore.collection('users').doc(userId).update({'email': newEmail});
      Logger.log('User email updated successfully');
    } catch (e) {
      Logger.log('Error updating user email: $e');
    }
  }

  Future<List<DocumentSnapshot>> searchUsersByEmail(String email) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('users').where('email', isEqualTo: email).get();
      return snapshot.docs;
    } catch (e) {
      Logger.log('Error searching users by email: $e');
      return [];
    }
  }
}
