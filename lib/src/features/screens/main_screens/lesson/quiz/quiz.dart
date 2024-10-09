import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/common_widgets/custom_alert_dialog.dart';
import 'package:taga_cuyo/src/features/constants/capitalize.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/features/services/progress_service.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';

class LessonQuizScreen extends StatefulWidget {
  final String lessonName;
  final String documentId;

  const LessonQuizScreen({
    super.key,
    required this.lessonName,
    required this.documentId,
  });

  @override
  LessonQuizScreenState createState() => LessonQuizScreenState();
}

class LessonQuizScreenState extends State<LessonQuizScreen> {
  final LessonProgressService _progressService = LessonProgressService();
  late int completedLessons = 0; // Default value of 0
  final AuthService _authService = AuthService();
  int _currentQuizIndex = 0;
  List<String> _quizIds = [];
  List<Map<String, dynamic>> _words = [];
  bool _isLoading = true;
  int _currentWordIndex = 0;
  final TextEditingController _translationController = TextEditingController();
  Set<String> selectedOptions = {};

  @override
  void initState() {
    super.initState();
    _fetchWords();
    _initializeCompletedLessons();
  }

  Future<void> _initializeCompletedLessons() async {
    String? userId = _authService.getUserId();
    if (userId != null) {
      completedLessons = await _progressService.getCompletedLessons(userId);
      Logger.log('Completed Lessons: $completedLessons');
    } else {
      Logger.log('User ID is null.');
    }
  }

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
  }

  Future<void> _updateLessonProgress() async {
    try {
      String? userId = _authService.getUserId();
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User is not logged in.')),
        );
        return;
      }

      DocumentReference userProgressDocRef =
          FirebaseFirestore.instance.collection('user_progress').doc(userId);

      DocumentSnapshot userProgressDoc = await userProgressDocRef.get();

      bool isCompleted =
          (userProgressDoc.data() as Map<String, dynamic>?)?['lessons_progress']
                  ?[widget.documentId]?['isCompleted'] ??
              false;

      if (isCompleted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You have already completed this lesson.')),
        );
        return;
      }

      // Proceed to update only if not completed
      await userProgressDocRef.set({
        'lessons': FieldValue.increment(1),
        'lessons_progress': {
          widget.documentId: {
            'isCompleted': true, // Set to true after completing the lesson
          },
        },
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lesson progress updated!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating lesson progress: $e')),
      );
    }
  }

  Future<void> _fetchWords() async {
    try {
      Logger.log('Fetching words for lesson: ${widget.lessonName}');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lessons')
          .where('lesson_name', isEqualTo: widget.lessonName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final lessonDoc = querySnapshot.docs[0];
        Logger.log('Lesson found: ${lessonDoc.id}');

        final wordsSnapshot =
            await lessonDoc.reference.collection('words').get();
        if (wordsSnapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> words = [];
          _quizIds = querySnapshot.docs.map((doc) => doc.id).toList();
          for (var doc in wordsSnapshot.docs) {
            final data = doc.data();

            // Retrieve options
            List<String> options = List<String>.from(data['options'] ?? []);

            // Shuffle options
            options.shuffle(); // Shuffle the options

            words.add({
              'word': data['word'],
              'translated': data['translated'],
              'options': options,
            });
          }

          setState(() {
            _words = words;
            _isLoading = false;
          });
        } else {
          setState(() {
            _words = [];
            _isLoading = false;
          });
        }
      } else {
        setState(() {
          _words = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mali: $e')),
      );
    }
  }

  Future<void> _checkAnswer() async {
    if (_words.isNotEmpty && _currentWordIndex < _words.length) {
      String selectedAnswer = selectedOptions
          .join(' ')
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim()
          .toLowerCase();

      String expectedTranslation =
          _words[_currentWordIndex]['translated'].trim().toLowerCase();

      if (expectedTranslation == selectedAnswer) {
        if (_currentWordIndex < _words.length - 1) {
          setState(() {
            _currentWordIndex++;
            selectedOptions.clear();
            _updateTextField();
          });
        } else {
          if (_currentQuizIndex < _quizIds.length - 1) {
            _loadNextQuiz();
          } else {
            // Update lesson progress when the last quiz is completed
            await _updateLessonProgress(); // Call the update method here
            _showCompletionDialog();
          }
          showCustomAlertDialog(
            context,
            'Binabati kita!',
            'Natapos na ang pagsubok sa aralin.',
            buttonText: 'OK!', // Custom button text
          );
        }
      } else {
        showCustomAlertDialog(
          context,
          'Oops!',
          'Mali ang iyong sagot, uliting muli!',
          buttonText: 'OK!', // Custom button text
        );
      }
    }
  }

  void _loadNextQuiz() async {
    setState(() {
      _currentQuizIndex++;
      _currentWordIndex = 0; // Reset word index for new quiz
      selectedOptions.clear();
      _translationController.clear(); // Clear the text field
      _fetchWords(); // Fetch words for the new quiz
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Binabati kita!'),
          content: const Text('Natapos ma na ang pagsubok sa aralin.'),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pop(
                    context); // Optionally navigate back to previous screen
              },
            ),
          ],
        );
      },
    );
  }

  void _toggleOption(String option) {
    setState(() {
      if (selectedOptions.contains(option)) {
        selectedOptions.remove(option); // Remove option if already selected
      } else {
        selectedOptions.add(option); // Add option if not selected
      }
      _updateTextField(); // Update the text field based on selection
    });
  }

  void _updateTextField() {
    _translationController.text =
        selectedOptions.join(' '); // Join selected options with a comma
  }

  @override
  Widget build(BuildContext context) {
    // Calculate progress based on total words in the current quiz
    double progress = _words.isNotEmpty
        ? (_currentWordIndex + 1) / _words.length // Total words in current quiz
        : 0;

    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(0, 60, 0, 20),
                  child: Column(
                    children: [
                      Text(
                        textAlign: TextAlign.center,
                        '${widget.documentId}:',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 97, 97, 97),
                        ),
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        widget.lessonName,
                        style: const TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 30),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Isalin ang pangungusap na ito',
                    style: TextStyle(
                      fontFamily: AppFonts.kanitLight,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildQuestionContainer(),
              _buildTranslationTextField(),
              _buildOptions(),
              const Spacer(),
              MyButton(
                onTab: () {
                  if (selectedOptions.isNotEmpty) {
                    _checkAnswer(); // Check answer against selected options
                  } else {
                    showCustomAlertDialog(
                      context,
                      'Oops!',
                      'Kailangan mong pumili ng sagot',
                      buttonText: 'OK!', // Custom button text
                    );
                  }
                },
                text: 'Isumite',
              ),
              const SizedBox(height: 20), // Added spacing
              LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.primaryBackground
                    .withOpacity(0.3), // Optional: light background
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.accentColor), // Use primary color for progress
              ),
              const SizedBox(
                  height: 20), // Add padding below progress indicator
            ],
          ),
          Positioned(
            top: 40, // Adjust this value to position vertically
            right: 30, // Adjust this value to position horizontally
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.circular(50), // Circular border for the icon
                border: Border.all(
                  width: 1,
                  color: Colors.black, // Optional: Add a color to the border
                ),
              ),
              child: IconButton(
                icon: const Icon(Icons.close),
                padding: EdgeInsets
                    .zero, // Remove padding to fit the icon inside the border
                alignment:
                    Alignment.center, // Center the icon inside the container
                iconSize: 20, // Adjust icon size if needed
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContainer() {
    return Container(
      height: MediaQuery.of(context).size.width / 2.5,
      padding: const EdgeInsets.fromLTRB(0, 25, 0, 25),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center, // Center the row items
        children: [
          Image.asset(
            'assets/images/teacher.png',
            height: 140,
            width: 140,
          ),
          const SizedBox(
              width:
                  10), // Add spacing between the image and the text container
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(15),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.width / 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Center(
                  // Center the content within this container
                  child: _isLoading
                      ? const Text(
                          'Loading...',
                          style: TextStyle(fontSize: 16),
                        )
                      : _words.isNotEmpty && _currentWordIndex < _words.length
                          ? Text(
                              capitalizeFirstLetter(
                                  _words[_currentWordIndex]['word']),
                              textAlign:
                                  TextAlign.center, // Center text alignment
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontFamily: AppFonts.kanitLight,
                                  fontWeight: FontWeight.w900),
                            )
                          : const Text(
                              'Hindi matagpuan ang salita',
                              textAlign:
                                  TextAlign.center, // Center text alignment
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationTextField() {
    return Padding(
      padding: const EdgeInsets.all(28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'i-click ang text sa pagpipilian upang alisin',
            style: TextStyle(
              fontFamily: AppFonts.kanitLight,
              fontSize: 14,
              fontStyle: FontStyle.italic, // Correct way to italicize text
            ),
          ),
          const SizedBox(
              height: 10), // Add some spacing between the text and text field
          GestureDetector(
            onTap: () {
              setState(() {
                selectedOptions
                    .clear(); // Clear selected options when text field is tapped
                _translationController.clear(); // Clear the text field
              });
            },
            child: Container(
              height: 120, // Same height as the TextField
              alignment: Alignment.center, // Center the text horizontally
              decoration: BoxDecoration(
                border:
                    Border.all(width: 1.0, color: Colors.black), // Same border
                borderRadius: BorderRadius.circular(
                    4.0), // Similar border radius as OutlineInputBorder
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 20.0), // Same vertical padding
                child: Text(
                  _translationController
                      .text, // Display the same text from the controller
                  textAlign: TextAlign.center, // Center the text horizontally
                  style: const TextStyle(
                      fontSize: 16.0), // Add text styling as needed
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptions() {
    if (_isLoading || _words.isEmpty || _currentWordIndex >= _words.length) {
      return const Center(child: CircularProgressIndicator());
    }

    final options = _words[_currentWordIndex]['options'] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Pagpipilian',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          options.isNotEmpty
              ? Center(
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    alignment: WrapAlignment.center,
                    children: options.map<Widget>((option) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 4.0),
                        child: GestureDetector(
                          onTap: () => _toggleOption(option),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: selectedOptions.contains(option)
                                  ? Colors.lightBlue[100]
                                  : AppColors.primary,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Text(
                              option, // Display each option here
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                )
              : const Text('Hindi available ang pagpipilian',
                  style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
