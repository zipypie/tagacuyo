import 'package:cloud_firestore/cloud_firestore.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Search for a user by UID
  Future<DocumentSnapshot?> getUserById(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        print("User found: ${userDoc.data()}");
      } else {
        print("No user found with UID: $uid");
      }
      return userDoc.exists ? userDoc : null;
    } catch (e) {
      print("Error getting user by ID: $e");
      return null;
    }
  }

  // Search for users by first name
  Future<List<DocumentSnapshot>> searchUsersByFirstName(String firstName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('firstname', isEqualTo: firstName)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error searching users by first name: $e");
      return [];
    }
  }

  // Search for users by last name
  Future<List<DocumentSnapshot>> searchUsersByLastName(String lastName) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('lastname', isEqualTo: lastName)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error searching users by last name: $e");
      return [];
    }
  }

  // Example method to search users by email
  Future<List<DocumentSnapshot>> searchUsersByEmail(String email) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      print("Error searching users by email: $e");
      return [];
    }
  }

  updateUserEmail(String uid, String text) {}
}
