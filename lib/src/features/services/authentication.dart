import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthServicews {
  // For storing data in Cloud Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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
