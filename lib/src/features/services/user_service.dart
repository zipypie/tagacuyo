import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';
import 'package:taga_cuyo/src/models/session_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

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

Future<String?> createUserSession(String uid, DateTime startTime) async {
  final userSessionRef = _firestore.collection('user_session').doc(uid);
  
  // Create a session entry
  final sessionId = userSessionRef.collection('sessions').doc().id; // Generate a new session ID
  await userSessionRef.collection('sessions').doc(sessionId).set({
    'sessionId': sessionId,
    'startTime': startTime,
    'endTime': null, // Initially, endTime is null
  });

  // Store session locally as well
  await _storeSessionLocally(sessionId, startTime, null); // Store endTime as null initially

  return sessionId; // Return the generated session ID
}

// Method to store session locally using Hive
Future<void> _storeSessionLocally(String sessionId, DateTime startTime, DateTime? endTime) async {
  final box = await Hive.openBox<SessionModel>('sessionBox');
  
  final session = SessionModel(sessionId: sessionId, startTime: startTime, endTime: endTime);
  
  await box.put(sessionId, session); // Store the session in Hive
}


  

  // Get the ID of the active session for the user
  Future<String?> getActiveSessionId(String uid) async {
    final userSessionRef = _firestore.collection('user_session').doc(uid);

    // Query to get the active session where endTime is null
    final snapshot = await userSessionRef.collection('sessions')
        .where('endTime', isEqualTo: null)
        .limit(1) // Limit to 1 to get only the active session
        .get();

    // If an active session is found, return its ID
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.id; // Return the ID of the active session
    }
    return null; // No active session found
  }

  // End user session and update the endTime
Future<void> endUserSession(String uid, String sessionId, DateTime endTime) async {
  final userSessionRef = _firestore.collection('user_session').doc(uid);

  try {
    // First, get the current session data to check the endTime
    final sessionDoc = await userSessionRef.collection('sessions').doc(sessionId).get();

    if (sessionDoc.exists) {
      final currentEndTime = sessionDoc.data()?['endTime'];
      final startTime = sessionDoc.data()?['startTime'].toDate(); // Assuming startTime is stored as a Timestamp

      // Only update if currentEndTime is null (the session is still active)
      if (currentEndTime == null) {
        // Try to update Firestore
        await userSessionRef.collection('sessions').doc(sessionId).update({
          'endTime': endTime,
        });
        
        // Also update the local record
        await _storeSessionLocally(sessionId, startTime, endTime); // Update endTime locally
        Logger.log('Session $sessionId ended at $endTime');
      } else {
        Logger.log('Session $sessionId already ended at $currentEndTime. No update performed.');
      }
    } else {
      Logger.log('Session $sessionId not found. Cannot update endTime.');
    }
  } catch (e) {
    // If there's an error (like no internet), store the end time locally with the start time
    final startTime = await _getSessionStartTimeLocally(sessionId);
    await _storeSessionLocally(sessionId, startTime, endTime);
    Logger.log('Error ending session: $e. Session end time stored locally.');
  }
}

// Method to retrieve startTime from local storage
Future<DateTime> _getSessionStartTimeLocally(String sessionId) async {
  final box = await Hive.openBox<SessionModel>('sessionBox');
  final session = box.get(sessionId);
  return session?.startTime ?? DateTime.now(); // Default to now if not found
}

// Method to sync local sessions to Firestore when online
Future<void> syncLocalSessionsToFirestore(String uid) async {
  final box = await Hive.openBox<SessionModel>('sessionBox');

  for (var sessionId in box.keys) {
    final session = box.get(sessionId);
    if (session != null) {
      final userSessionRef = _firestore.collection('user_session').doc(uid);

      // Attempt to update Firestore
      await userSessionRef.collection('sessions').doc(session.sessionId).set({
        'startTime': session.startTime,
        'endTime': session.endTime,
      });

      // Remove from local storage after successful sync
      await box.delete(session.sessionId);
    }
  }
}




  Future<void> incrementSessionMinutes(String userId, int minutes) async {
    try {
      await _firestore.collection('user_progress').doc(userId).update({
        'minutes': FieldValue.increment(minutes),
      });
      Logger.log('Session minutes incremented for user: $userId');
    } catch (e) {
      Logger.log('Error incrementing session minutes: $e');
    }
  }

}
