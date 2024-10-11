import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';

class StreakCounterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService authService = AuthService();

  // Calculate and update streak based on the days_active map
  Future<void> updateStreak() async {
    String? uid = authService.getUserId(); // Get the current user ID

    if (uid == null) {
      throw Exception("User is not logged in.");
    }

    DocumentReference userProgressRef = _firestore.collection('user_progress').doc(uid);

    try {
      // Retrieve user document
      DocumentSnapshot userDocSnapshot = await userProgressRef.get();
      Logger.log("Retrieved user document snapshot: ${userDocSnapshot.exists}");

      if (userDocSnapshot.exists) {
        Map<String, dynamic> userData = userDocSnapshot.data() as Map<String, dynamic>;

        // Get 'days_active' map, if it exists
        Map<String, dynamic> daysActiveMap = Map<String, dynamic>.from(userData['days_active'] ?? {});

        // Logger.log days_active for debugging
        Logger.log("Days Active Map: $daysActiveMap");

        // Calculate the streak based on the daysActiveMap
        await _calculateStreak(userProgressRef, daysActiveMap);
      } else {
        Logger.log("User document does not exist.");
      }
    } catch (e) {
      Logger.log("Error calculating streak: $e");
    }
  }

  // Calculate the current streak based on the 'days_active' map
  Future<void> _calculateStreak(DocumentReference userProgressRef, Map<String, dynamic> daysActiveMap) async {
    try {
      Logger.log("Calculating streak...");

      // Convert the keys from the map to DateTime objects
      List<DateTime> activeDates = daysActiveMap.keys.map((dateStr) {
        List<String> dateParts = dateStr.split('/');
        return DateTime(int.parse(dateParts[2]), int.parse(dateParts[0]), int.parse(dateParts[1]));
      }).toList();

      // Log the active dates for debugging
      Logger.log("Active Dates (Unsorted): $activeDates");

      // Sort dates in ascending order to calculate streak
      activeDates.sort();
      Logger.log("Active Dates (Sorted): $activeDates");

      int currentStreak = 0;
      int longestStreak = 0;
      DateTime? previousDate;

      // Calculate the streak
      for (DateTime currentDate in activeDates) {
        Logger.log("Checking date: $currentDate");

        // If the current date is consecutive to the previous date or the first date
        if (previousDate == null || currentDate.difference(previousDate).inDays == 1) {
          currentStreak++; // Increment the current streak
        } else {
          // If there's a gap, check if the current streak is the longest
          if (currentStreak > longestStreak) {
            longestStreak = currentStreak;
          }
          currentStreak = 1; // Reset current streak
        }
        previousDate = currentDate; // Update previousDate for the next iteration
      }

      // Final check for the last streak
      if (currentStreak > longestStreak) {
        longestStreak = currentStreak;
      }

      // Log the current streak and longest streak values before updating
      Logger.log("Current streak calculated: $currentStreak");
      Logger.log("Longest streak calculated: $longestStreak");

      // Update the user document with the new streak values
      await userProgressRef.update({
        'streak': currentStreak,
        'longest_streak': longestStreak,
      });
      Logger.log("Streak updated successfully. Current: $currentStreak, Longest: $longestStreak");
    } catch (error) {
      Logger.log("Failed to calculate or update streak: $error");
    }
  }
}
