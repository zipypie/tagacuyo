import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';

class DayCounterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  AuthService authService = AuthService();

  // Update the last active date and day count
  Future<void> updateDayInSession() async {
    String? uid = authService.getUserId();  // Get the current user ID using getUserId()

    if (uid != null) {
      DocumentReference userProgressRef = _firestore.collection('user_progress').doc(uid);
      DateTime currentDate = DateTime.now();
      String formattedDate = "${currentDate.month}/${currentDate.day}/${currentDate.year}";

      // Retrieve user document to get 'days_active'
      DocumentSnapshot userDocSnapshot = await userProgressRef.get();

      if (userDocSnapshot.exists) {
        Map<String, dynamic> userData = userDocSnapshot.data() as Map<String, dynamic>;

        // Get the 'days_active' map if it exists, otherwise create a new map
        Map<String, dynamic> daysActiveMap = Map<String, dynamic>.from(userData['days_active'] ?? {});

        // Only add the current date if it doesn't exist in the map
        if (!daysActiveMap.containsKey(formattedDate)) {
          daysActiveMap[formattedDate] = true;

          // Update the user document with the new date in the 'days_active' field and increment 'days'
          await userProgressRef.update({
            'days_active': daysActiveMap,  // Update 'days_active' with the new date
            'days': FieldValue.increment(1)  // Increment the 'days' count
          });
        }
      } else {
        // If no user document exists, create it and add the current date in 'days_active'
        await _createNewUserProgressWithDate(uid, formattedDate);
      }
    } else {
      throw Exception("User is not logged in.");
    }
  }

  // Create a new user progress document with the current date in 'days_active'
  Future<void> _createNewUserProgressWithDate(String uid, String formattedDate) async {
    final userProgressRef = _firestore.collection('user_progress').doc(uid);
    DateTime currentDate = DateTime.now();

    await userProgressRef.set({
      'startTime': currentDate,
      'days_active': {formattedDate: true},  // Add the formatted date in 'days_active'
      'days': 1  // Initialize 'days' count to 1
    });
  }
}
