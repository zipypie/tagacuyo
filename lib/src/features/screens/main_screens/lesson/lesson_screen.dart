import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/common_widgets/loading_animation/lesson_loading.dart';
import 'package:taga_cuyo/src/features/constants/capitalize.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/lesson/quiz/quiz.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/features/services/lesson_service.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';
import 'lesson_bloc.dart';
import 'lesson_event.dart';
import 'lesson_state.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/constants/images.dart';

class LessonScreenPage extends StatefulWidget {
  const LessonScreenPage({super.key});

  @override
  State<LessonScreenPage> createState() => _LessonScreenPageState();
}

class _LessonScreenPageState extends State<LessonScreenPage> {
  final AuthService _authService = AuthService();
  final lessonProgressService = LessonProgressService();
  late LessonBloc _lessonBloc;
  int lessonProgress = 0;
  int maxLength = 0;

  @override
  void initState() {
    super.initState();
    _lessonBloc = LessonBloc();
    _lessonBloc.addEvent(FetchLessonsEvent());
    _fetchLessonData();
  }

  Future<void> _fetchLessonData() async {
    String? userId = _authService.getUserId();

    if (userId != null) {
      try {
        // Fetch lesson progress
        DocumentSnapshot userProgressDoc = await FirebaseFirestore.instance
            .collection('user_progress')
            .doc(userId)
            .get();

        if (userProgressDoc.exists) {
          setState(() {
            lessonProgress =
                (userProgressDoc.data() as Map<String, dynamic>?)?['lessons'] ??
                    0;
          });
        }

        // Fetch max length
        QuerySnapshot lessonsSnapshot =
            await FirebaseFirestore.instance.collection('lessons').get();

        setState(() {
          maxLength = lessonsSnapshot.docs.length;
        });
      } catch (e) {
        // Handle errors (e.g., show a message to the user)
        Logger.log("Error fetching lesson data: $e");
      }
    }
  }

  @override
  void dispose() {
    _lessonBloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _lessonHeader(context),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<LessonState>(
              stream: _lessonBloc.stateStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return lessonShimmerLoading(); // Show shimmer loading when waiting
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.data is LessonLoading) {
                  return const Center(child: Text('Loading lessons...'));
                } else if (snapshot.data is LessonLoaded) {
                  List<Map<String, dynamic>> lessons =
                      (snapshot.data as LessonLoaded).lessons;
                  return SingleChildScrollView(
                    child: Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: lessons
                          .map((lesson) => _lessonListItem(
                              context, lesson, _authService.getUserId()!))
                          .toList(),
                    ),
                  );
                } else if (snapshot.data is LessonError) {
                  return Center(
                      child: Text((snapshot.data as LessonError).message));
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
      height: MediaQuery.of(context).size.height * 0.14,
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
      child: Padding(
        padding: const EdgeInsets.fromLTRB(25, 15, 0, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start, // Align items to start
          crossAxisAlignment: CrossAxisAlignment.start, // Align to the top
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                    right: 40), // Add right padding for space
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start, // Align text to the left
                  children: [
                    const Text(
                      'Maligayang pagdating sa Taga-Cuyo',
                      style: TextStyles.learningtitle,
                      textAlign: TextAlign.left, // Align text to the left
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        'Aralin $lessonProgress / $maxLength',
                        style: const TextStyle(
                          fontFamily: AppFonts
                              .fcr, // Ensure this font is defined in your pubspec.yaml
                          fontSize:
                              16, // You can adjust the font size as needed
                          color: Color.fromARGB(
                              255, 73, 109, 126), // Use a color if needed
                        ),
                        textAlign: TextAlign.left, // Align text to the left
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
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

  Widget _lessonListItem(
      BuildContext context, Map<String, dynamic> lesson, String userId) {
    double containerWidth = MediaQuery.of(context).size.width / 2 -
        37; // Half of screen width minus margin

    return GestureDetector(
      onTap: () {
        // Navigate to quiz screen with the lesson data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LessonQuizScreen(
              lessonName: lesson['lesson_name'] ?? 'Unknown Lesson',
              documentId: lesson['id'] ?? '',
            ),
          ),
        );
      },
      child: Column(
        children: [
          Text(
            '${lesson['id']}', // Use lesson id for the lesson number
            style: const TextStyle(
              fontFamily: AppFonts.fcr,
              fontSize: 18,
              color: Color.fromARGB(255, 156, 156, 156),
            ),
            textAlign: TextAlign.center, // Center the text
          ),
          Container(
            width: containerWidth,
            height: containerWidth, // Set height equal to width for a square
            margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
  
            child: FutureBuilder<bool>(
              future:
                  lessonProgressService.isLessonCompleted(userId, lesson['id']),
              builder: (context, snapshot) {
                // Check the connection state
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator()); // Centered loading state for completion check
                }

                // Check if there was an error or if the data is not available
                if (snapshot.hasError) {
                  return const Center(
                      child: Icon(Icons.error,
                          size: 60)); // Show error icon if there was an error
                }

                // Check if the lesson is completed
                if (snapshot.hasData && snapshot.data == true) {
                  // Change border color to green if completed
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.green, // Change border color to green
                        width: 12,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    // Place child widgets for completed lesson inside this Container
                    child: _buildLessonContent(lesson),
                  );
                } else {
                  // Default state for not completed
                  return Container(
                    decoration: BoxDecoration(
                      color: AppColors.primaryBackground,
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: AppColors.accentColor, // Default transparent border
                        width: 12,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    // Place child widgets for not completed lesson inside this Container
                    child: _buildLessonContent(lesson),
                  );
                }
              },
            ),
          ),
          // Move the lesson name outside the container
          Padding(
            padding: const EdgeInsets.symmetric(
                vertical: 4), // Optional padding for spacing
            child: Text(
              capitalizeFirstLetter(
                  lesson['lesson_name']), // Display lesson name safely
              style: const TextStyle(
                fontSize: 18,
                fontFamily: AppFonts.fcr,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
              textAlign: TextAlign.center, // Center the text
            ),
          ),
        ],
      ),
    );
  }

// Helper method to build lesson content
  Widget _buildLessonContent(Map<String, dynamic> lesson) {
    // This method can be used to create content for the lesson
    return Padding(
      padding: const EdgeInsets.all(8.0), // Padding around the image
      child: Column(
        children: [
          Expanded(
            child: FutureBuilder<String>(
              future: _lessonBloc.fetchImageFromStorage(
                  lesson['image_path'] ?? ''), // Use image_path directly
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child:
                          CircularProgressIndicator()); // Centered loading state for image
                }

                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                      child: Icon(Icons.error,
                          size: 60)); // Show error icon if image fetch fails
                }
                return FittedBox(
                  fit: BoxFit.cover, // Ensure image covers the box
                  child: Image.network(
                    snapshot.data!,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
