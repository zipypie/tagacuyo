import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

class LessonQuizScreen extends StatefulWidget {
  final String lessonName;
  final String documentId; // Added documentId parameter

  const LessonQuizScreen({
    Key? key,
    required this.lessonName,
    required this.documentId, // Added documentId to constructor
  }) : super(key: key);

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
      String selectedAnswer =
          selectedOptions.join(', '); // Join selected options for checking
      if (_words[_currentWordIndex]['translated'] == selectedAnswer) {
        if (_currentWordIndex < _words.length - 1) {
          setState(() {
            _currentWordIndex++;
            selectedOptions.clear(); // Clear selections for the next word
            _updateTextField(); // Update text field to reflect changes
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
        selectedOptions.join(', '); // Join selected options with a comma
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
                        '${widget.documentId}:',
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 97, 97, 97)),
                      ),
                      Text(
                        '${widget.lessonName}',
                        style: const TextStyle(
                            fontSize: 24,
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
                    style:
                        TextStyle(fontFamily: AppFonts.kanitLight, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildQuestionContainer(),
              const SizedBox(height: 16),
              _buildTranslationTextField(),
              const SizedBox(height: 16),
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
            right: 40, // Adjust this value to position horizontally
            child: IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContainer() {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Expanded(
            child: _isLoading
                ? const Text('Loading...', style: TextStyle(fontSize: 16))
                : _words.isNotEmpty && _currentWordIndex < _words.length
                    ? Text(
                        _words[_currentWordIndex]['word'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const Text(
                        'No words available for this lesson.',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTranslationTextField() {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedOptions
              .clear(); // Clear selected options when text field is tapped
          _translationController.clear(); // Clear the text field
        });
      },
      child: TextField(
        controller: _translationController,
        readOnly: true, // Set to true to make it read-only
        maxLines: 4,
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(width: 1.0, color: Colors.black),
          ),
        ),
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
            : const Text('No options available',
                style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
