import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

class LessonQuizScreen extends StatefulWidget {
  final String lessonName;
  final String documentId; // Added documentId parameter

  const LessonQuizScreen({
    super.key,
    required this.lessonName,
    required this.documentId, // Added documentId to constructor
  });

  @override
  _LessonQuizScreenState createState() => _LessonQuizScreenState();
}

class _LessonQuizScreenState extends State<LessonQuizScreen> {
  List<Map<String, dynamic>> _words = [];
  bool _isLoading = true;
  int _currentWordIndex = 0;
  final TextEditingController _translationController = TextEditingController();
  Set<String> selectedOptions = {}; // Track selected options

  @override
  void initState() {
    super.initState();
    _fetchWords();
  }

  @override
  void dispose() {
    _translationController.dispose();
    super.dispose();
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

          for (var doc in wordsSnapshot.docs) {
            final data = doc.data();
            print('Raw word document data: $data'); // Print raw data to debug

            // Use this line to retrieve options with debug logging
            List<String> options = List<String>.from(data['options'] ?? []);
            print('Retrieved options: $options'); // Log retrieved options

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

void _checkAnswer() {
  if (_words.isNotEmpty && _currentWordIndex < _words.length) {
    // Join selected options into a single string and normalize spaces
    String selectedAnswer = selectedOptions.join(' ')
        .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with a single space
        .trim()
        .toLowerCase(); // Normalize case

    String expectedTranslation = _words[_currentWordIndex]['translated']
        .trim()
        .toLowerCase(); // Normalize case
  

    if (expectedTranslation == selectedAnswer) {
      if (_currentWordIndex < _words.length - 1) {
        setState(() {
          _currentWordIndex++;
          selectedOptions.clear();
          _updateTextField();
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiz completed!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect answer! Try again.')),
      );
    }
  }
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
        color: Colors.lightBlue[50],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            'assets/images/monkey.png',
            height: 100,
            width: 100,
          ),
          const SizedBox(width: 16),
          Container(
            color: AppColors.secondaryBackground,
            child: SizedBox(
              width: MediaQuery.of(context).size.width / 2,
              height: MediaQuery.of(context).size.width / 4,
              child: Center(
                // Use Center to center the content vertically and horizontally
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
                              fontWeight: FontWeight.bold,
                            ),
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

    return Column(
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
                                : Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
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
    );
  }
}
