import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';

class LessonProgressService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;


  Future<int> getCompletedLessons(String userId) async {
    DocumentReference userLessonProgressDoc = _firestore.collection('userLessonProgress').doc(userId);

    DocumentSnapshot snapshot = await userLessonProgressDoc.get();

    if (snapshot.exists) {
      Map<String, dynamic> userLessonProgressData = snapshot.data() as Map<String, dynamic>;
      return userLessonProgressData['completedLessons'] ?? 0;
    } else {
      Logger.log('User LessonProgress document does not exist.');
      return 0; 
    }
  }


  Future<void> updateLessonProgress(String documentId, String userId) async {
    try {
      DocumentReference userProgressDocRef =
          FirebaseFirestore.instance.collection('user_progress').doc(userId);

      DocumentSnapshot userProgressDoc = await userProgressDocRef.get();

      bool isCompleted =
          (userProgressDoc.data() as Map<String, dynamic>?)?['lessons_progress']
                  ?[documentId]?['isCompleted'] ??
              false;

      if (isCompleted) {
        throw Exception('Lesson already completed');
      }

      await userProgressDocRef.set({
        'lessons': FieldValue.increment(1),
        'lessons_progress': {
          documentId: {
            'isCompleted': true,
          },
        },
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Error updating lesson progress: $e');
    }
  }

  Future<List<Map<String, dynamic>>> fetchWords(String lessonName) async {
    try {
      Logger.log('Fetching words for lesson: $lessonName');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lessons')
          .where('lesson_name', isEqualTo: lessonName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final lessonDoc = querySnapshot.docs[0];
        Logger.log('Lesson found: ${lessonDoc.id}');

        final wordsSnapshot =
            await lessonDoc.reference.collection('words').get();

        List<Map<String, dynamic>> words = [];
        for (var doc in wordsSnapshot.docs) {
          final data = doc.data();
          List<String> options = List<String>.from(data['options'] ?? []);
          options.shuffle();
          words.add({
            'word': data['word'],
            'translated': data['translated'],
            'options': options,
          });
        }
        return words;
      } else {
        return []; // Return empty list if no lesson found
      }
    } catch (e) {
      Logger.log('Error fetching words: $e');
      return []; // Return empty list in case of error
    }
  }

 Future<bool> isLessonCompleted(String userId, String documentId) async {
    try {
      DocumentReference userProgressDocRef = FirebaseFirestore.instance.collection('user_progress').doc(userId);
      DocumentSnapshot userProgressDoc = await userProgressDocRef.get();

      // Check if the document exists and then retrieve the isCompleted status
      if (userProgressDoc.exists) {
        return (userProgressDoc.data() as Map<String, dynamic>?)?['lessons_progress']?[documentId]?['isCompleted'] ?? false;
      } else {
        Logger.log('User progress document does not exist.');
        return false; // Return false if the document does not exist
      }
    } catch (e) {
      Logger.log('Error checking lesson completion: $e');
      return false; // Return false in case of error
    }
  }

}
