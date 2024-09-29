import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/features/services/progress_service.dart';

class LessonQuizScreen extends StatefulWidget {
  final String lessonName;
  final String documentId;

  const LessonQuizScreen({
    super.key,
    required this.lessonName,
    required this.documentId,
  });

  @override
  _LessonQuizScreenState createState() => _LessonQuizScreenState();
}

class _LessonQuizScreenState extends State<LessonQuizScreen> {
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
      completedLessons = await _progressService.getCompletedLessons(userId); // Use correct service instance
      print('Completed Lessons: $completedLessons');
    } else {
      print('User ID is null.');
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

    DocumentReference userProgressDocRef = FirebaseFirestore.instance
        .collection('user_progress')
        .doc(userId);

    DocumentSnapshot userProgressDoc = await userProgressDocRef.get();

    bool isCompleted = (userProgressDoc.data() as Map<String, dynamic>?)?['lessons_progress']?[widget.documentId]?['isCompleted'] ?? false;

    if (isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already completed this lesson.')),
      );
      return;
    }

    // Proceed to update only if not completed
    print('Updating user progress for lesson ID: ${widget.documentId}');
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
    print('Error updating lesson progress: $e');
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error updating lesson progress: $e')),
    );
  }
}


  Future<void> _fetchWords() async {
    try {
      print('Fetching words for lesson: ${widget.lessonName}');
      final querySnapshot = await FirebaseFirestore.instance
          .collection('lessons')
          .where('lesson_name', isEqualTo: widget.lessonName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final lessonDoc = querySnapshot.docs[0];
        print('Lesson found: ${lessonDoc.id}');

        final wordsSnapshot =
            await lessonDoc.reference.collection('words').get();
        if (wordsSnapshot.docs.isNotEmpty) {
          List<Map<String, dynamic>> words = [];
          _quizIds = querySnapshot.docs.map((doc) => doc.id).toList();
          for (var doc in wordsSnapshot.docs) {
            final data = doc.data();
            print('Raw word document data: $data'); // Print raw data to debug

            // Retrieve options
            List<String> options = List<String>.from(data['options'] ?? []);
            print('Retrieved options: $options'); // Log retrieved options

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

          print('Final fetched words: $_words');
        } else {
          print('No words found for lesson ${widget.lessonName}');
          setState(() {
            _words = [];
            _isLoading = false;
          });
        }
      } else {
        print('No lesson found with name ${widget.lessonName}');
        setState(() {
          _words = [];
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching words: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching words: $e')),
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
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Quiz completed!')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect answer! Try again.')));
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
          title: const Text('Congratulations!'),
          content: const Text('You have successfully completed the aralin.'),
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
    return Scaffold(
      body: Stack(
        children: [
          Column(
            mainAxisAlignment:
                MainAxisAlignment.center, // Center all children vertically
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
                            color: Color.fromARGB(255, 97, 97, 97)),
                      ),
                      Text(
                        textAlign: TextAlign.center,
                        widget.lessonName,
                        style: const TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 30),
                child: Align(
                  alignment:
                      Alignment.centerLeft, // Aligns the text to the left
                  child: Text(
                    'Isalin ang pangungusap na ito',
                    style: TextStyle(
                        fontFamily: AppFonts.kanitLight, fontSize: 18),
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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Pumili sa option')),
                    );
                  }
                },
                text: 'Isumite',
              ),
              const SizedBox(height: 20),
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
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.lightBlue[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/monkey.png',
            height: 120,
            width: 120,
          ),
          const SizedBox(width: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBackground,
              borderRadius: BorderRadius.circular(25), // Moved to Container
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.width / 4,
              child: Center(
                child: _isLoading
                    ? const Text(
                        'Loading...',
                        style: TextStyle(fontSize: 16),
                      )
                    : _words.isNotEmpty && _currentWordIndex < _words.length
                        ? Text(
                            _words[_currentWordIndex]['word'],
                            style: const TextStyle(
                                fontSize: 16,
                                fontFamily: AppFonts.kanitLight,
                                fontWeight: FontWeight.w900),
                          )
                        : const Text(
                            'Hindi matagpuan ang salita',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
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
