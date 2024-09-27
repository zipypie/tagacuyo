import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/lesson/quiz/quiz.dart';
import 'lesson_bloc.dart'; // Import the BLoC
import 'lesson_event.dart'; // Import the events
import 'lesson_state.dart'; // Import the states
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/constants/images.dart';

class LessonScreenPage extends StatefulWidget {
  const LessonScreenPage({super.key});

  @override
  State<LessonScreenPage> createState() => _LessonScreenPageState();
}

class _LessonScreenPageState extends State<LessonScreenPage> {
  late LessonBloc _lessonBloc;

  @override
  void initState() {
    super.initState();
    _lessonBloc = LessonBloc();
    _lessonBloc.addEvent(FetchLessonsEvent()); // Trigger fetch on init
  }

  @override
  void dispose() {
    _lessonBloc.dispose(); // Dispose the BLoC
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _lessonHeader(context),
          const SizedBox(height: 20), // Add some space between header and list items
          Expanded(
            child: StreamBuilder<LessonState>(
              stream: _lessonBloc.stateStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                // Check the current state
                if (snapshot.data is LessonLoading) {
                  return const Center(child: Text('Loading lessons...'));
                } else if (snapshot.data is LessonLoaded) {
                  List<Map<String, dynamic>> lessons =
                      (snapshot.data as LessonLoaded).lessons;
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 10, // Horizontal space between items
                      runSpacing: 10, // Vertical space between items
                      children: lessons.map((lesson) => _lessonListItem(context, lesson)).toList(),
                    ),
                  );
                } else if (snapshot.data is LessonError) {
                  return Center(child: Text((snapshot.data as LessonError).message));
                }

                return const Center(child: Text('No lessons available.'));
              },
            ),
          ),
        ],
      ),
    );
  }

  // Header Section
  Widget _lessonHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: MediaQuery.of(context).size.height * 0.12,
      decoration: BoxDecoration(
        gradient: AppColors.boxGradient,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2), // Shadow color
            spreadRadius: 2, // Spread radius of the shadow
            blurRadius: 5, // Blur radius of the shadow
            offset: const Offset(0, 2), // Position of the shadow
          ),
        ],
      ),
      child: const Padding(
        padding: EdgeInsets.fromLTRB(25, 0, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align items to start
          crossAxisAlignment: CrossAxisAlignment.center, // Align to the top
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: 10), // Add right padding for space
                child: Text(
                  'Maligayang pagdating sa Taga-Cuyo',
                  style: TextStyles.subtitle,
                  textAlign: TextAlign.left, // Align text to the left
                ),
              ),
            ),
            SizedBox(
              child: CustomImage(
                src: 'assets/images/monkey.png',
                width: 100, // Fixed width for the image
                height: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Lesson List Item with Navigation
  Widget _lessonListItem(BuildContext context, Map<String, dynamic> lesson) {
    return GestureDetector(
      onTap: () {
        // Navigate to quiz screen with the lesson data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonQuizScreen(
              lessonName: lesson['lesson_name'] ?? 'Unknown Lesson', // Pass lesson_name safely
              documentId: lesson['id'] ?? '', // Pass lesson ID safely
            ),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 2 - 40, // Calculate half width minus margin
        margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6), // Space between items
        decoration: BoxDecoration(
          color: AppColors.secondaryBackground,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                '${lesson['id']}', // Use lesson id for the lesson number
                style: TextStyles.learningtitle,
              ),
              const CustomImage(
                src: 'assets/images/monkey.png',
                width: 100,
                height: 100,
              ),
              Text(
                lesson['lesson_name'] ?? 'Unknown Lesson', // Display lesson name safely
                style: TextStyles.learningtitle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
