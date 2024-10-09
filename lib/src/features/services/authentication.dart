import 'package:firebase_auth/firebase_auth.dart'; 
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get the current user
  User? get currentUser => _auth.currentUser;

  // Get the current user's ID
  String? getUserId() {
    return currentUser?.uid; // Return the user's ID if they are logged in
  }

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
    if (currentUser != null && currentUser!.email != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: currentUser!.email!,
        password: password,
      );
      await currentUser!.reauthenticateWithCredential(credential);
    }
  }

  // Update user email in Firebase Auth with verification
  Future<void> updateFirebaseUserEmail(String email, String password) async {
    if (currentUser != null) {
      try {
        // Reauthenticate the user before updating the email
        await reauthenticateUser(password);
        
        // Send verification email for new email address
        await currentUser!.verifyBeforeUpdateEmail(email);
        
        // Update the email in Firestore (optional, can be done after verification)
        await updateUserEmail(email);
        
        Logger.log('Verification email sent to $email.');
      } catch (e) {
        Logger.log('Failed to update email: ${e.toString()}');
        rethrow; // Rethrow the exception for further handling
      }
    }
  }

  // Sign out the user
Future<String> signUpUser({
  required String firstname,
  required String lastname,
  required String email,
  required String password,
  required int age, // Now using int for age
  required String gender,
  String? profileImage,
}) async {
  String res = "Some error occurred";
  try {
    // Create a user with email and password
    UserCredential credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    String uid = credential.user!.uid;

    // Add user details to Firestore
    await _firestore.collection('users').doc(uid).set({
      'firstname': firstname,
      'lastname': lastname,
      'email': email,
      'age': age, // Now using int for age
      'gender': gender,
      'uid': uid,
      'date_joined': DateTime.now(),
      'profile_image': profileImage ?? '', // Default to empty string if null
    });

    // Add progress details to 'user_progress' collection with default values
    await _firestore.collection('user_progress').doc(uid).set({
      'categories': 0,  // Default value
      'days': 0,        // Default value
      'lessons': 0,     // Default value
      'minutes': 0,     // Default value
      'streak': 0,      // Default value
    });

    res = "Success";
  } catch (e) {
    Logger.log(e.toString());
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
      Logger.log(e.toString());
      res['res'] = e.toString();
    }
    return res;
  }
}
