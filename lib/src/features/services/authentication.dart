// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Fetch user data from Firestore
  Future<DocumentSnapshot?> getUserData() async {
    if (currentUser != null) {
      return await _firestore.collection('users').doc(currentUser!.uid).get();
    }
    return null;
  }

  // Update user email in Firestore
  Future<void> updateUserEmail(String email) async {
    if (currentUser != null) {
      await _firestore.collection('users').doc(currentUser!.uid).update({
        'email': email,
      });
    }
  }

  // Reauthenticate user
  Future<void> reauthenticateUser(String password) async {
    if (currentUser != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );
      await currentUser!.reauthenticateWithCredential(credential);
    }
  }

  // Update user email in Firebase Auth
  Future<void> updateFirebaseUserEmail(String email) async {
    if (currentUser != null) {
      await currentUser!.updateEmail(email);
    }
  }

  // Sign out the user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Sign up a user
  Future<String> signUpUser({
    required String firstname,
    required String lastname,
    required String email,
    required String password,
    required String age,
    required String gender,
  }) async {
    String res = "Some error occurred";
    try {
      // Create a user with email and password
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Add user details to Firestore
      await _firestore.collection('users').doc(credential.user?.uid).set({
        'firstname': firstname,
        'lastname': lastname,
        'email': email,
        'age': age,
        'gender': gender,
        'uid': credential.user!.uid,
      });

      res = "Success";
    } catch (e) {
      print(e.toString());
      res = e.toString();
    }
    return res;
  }

  // Log in a user
  Future<Map<String, dynamic>> signInUser({
    required String email,
    required String password,
  }) async {
    Map<String, dynamic> res = {
      'res': "Some error occurred",
      'uid': null,
    };
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      res['res'] = "Success";
      res['uid'] = credential.user?.uid; // Save the UID for further use
    } catch (e) {
      print(e.toString());
      res['res'] = e.toString();
    }
    return res;
  }
}
