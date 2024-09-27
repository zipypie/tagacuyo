import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';

class LessonBloc {
  final CollectionReference lessonsCollection = FirebaseFirestore.instance.collection('lessons');

  // Stream controllers for managing lesson events and states
  final _eventController = StreamController<LessonEvent>();
  final _stateController = StreamController<LessonState>();

  Stream<LessonState> get stateStream => _stateController.stream;

  LessonBloc() {
    // Listen to events and process them
    _eventController.stream.listen(_mapEventToState);
  }

  // Method to handle incoming events
  void _mapEventToState(LessonEvent event) {
    if (event is FetchLessonsEvent) {
      _fetchLessons();
    }
  }

  // Fetch lessons and emit states
  Future<void> _fetchLessons() async {
    _stateController.sink.add(LessonLoading());

    try {
      List<Map<String, dynamic>> lessonsList = [];
      QuerySnapshot snapshot = await lessonsCollection.get();

      for (var doc in snapshot.docs) {
        // Use the containsKey utility function to check if the field exists
        String lessonName = _containsKey(doc, 'lesson_name')
            ? doc['lesson_name']
            : 'No name provided'; // Default value if the field is missing

        lessonsList.add({
          'id': doc.id,
          'lesson_name': lessonName,
        });
      }

      _stateController.sink.add(LessonLoaded(lessonsList));
    } catch (error) {
      _stateController.sink.add(LessonError('Error fetching lessons: $error'));
    }
  }

  // Utility method to check if the document contains a specific key
  bool _containsKey(DocumentSnapshot doc, String key) {
    return doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey(key);
  }

  // Method to add events to the event controller
  void addEvent(LessonEvent event) {
    _eventController.sink.add(event);
  }

  void dispose() {
    _eventController.close();
    _stateController.close();
  }
}
