import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore for accessing the database
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/services/category_service.dart';

class NextQuizScreen extends StatefulWidget {
  final String title;
  final String subcategoryTitle;
  final String currentWord; // Pass the current word for fetching the next one
  final String userId; // Add userId parameter

  const NextQuizScreen({
    super.key,
    required this.title,
    required this.subcategoryTitle,
    required this.currentWord,
    required this.userId, // Initialize userId
  });

  @override
  State<NextQuizScreen> createState() => _NextQuizScreenState();
}

class _NextQuizScreenState extends State<NextQuizScreen> {
  bool _isCorrect = false;
  bool _isAnswered = false;
  String correctAnswer = '';
  List<dynamic> options = [];
  String? selectedOption; // Store selected option
  int _currentWordIndex = 0; // Track the current word index
  List<Map<String, dynamic>> dataList = []; // Store fetched data
  final CategoryProgressService _categoryProgressService = CategoryProgressService(); // Create an instance

  @override
  void initState() {
    super.initState();
    fetchNextSubcategoryData(); // Fetch data on init
  }

  @override
  Widget build(BuildContext context) {
    if (dataList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_currentWordIndex >= dataList.length) {
      // Show congratulations dialog if all questions have been answered
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showCongratulationsDialog();
      });
      return const Center(child: Text('No more questions available.'));
    }

    final data = dataList[_currentWordIndex];
    final title = data['word'];
    correctAnswer = data['translated'];
    options = data['options'];

    return Scaffold(
      body: Stack( // Use Stack to overlay the close button
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(height: 30),
                _headerTitle(context, title, widget.subcategoryTitle),
                const SizedBox(height: 20),
                _imageWithWordContainer(context, data['image'], title),
                const SizedBox(height: 40),
                _notifText(),
                const SizedBox(height: 40),
                _buildOptions(context, options),
                if (_isAnswered && !_isCorrect)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Please try again',
                      style: TextStyle(color: Colors.red, fontSize: 18),
                    ),
                  ),
                const Spacer(),
                if (_isAnswered && _isCorrect)
                  MyButton(
                    onTab: () {
                      setState(() {
                        _currentWordIndex++;
                        _isAnswered = false;
                        selectedOption = null;
                      });
                    },
                    text: 'Next',
                  ),
                if (_isAnswered && !_isCorrect)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: MyButton(
                      onTab: () {
                        setState(() {
                          _isAnswered = false;
                          selectedOption = null;
                        });
                      },
                      text: 'Try Again',
                    ),
                  ),
              ],
            ),
          ),
          _buildCloseButton(context), // Place the close button in the Stack
        ],
      ),
    );
  }

  Future<void> fetchNextSubcategoryData() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.title)
          .collection('subcategories')
          .doc(widget.subcategoryTitle)
          .collection('words') // Assuming you have a collection for quizzes
          .where('word', isGreaterThan: widget.currentWord) // Get the next word
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          dataList = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      } else {
        // If no more questions are available, show congratulations dialog
        _showCongratulationsDialog();
      }
    } catch (e) {
      print('Error fetching next subcategory data: $e');
    }
  }

  void _showCongratulationsDialog() {
    // Increment completed categories when the dialog is shown
    _categoryProgressService.incrementCompletedCategories(widget.userId);

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have completed all the quizzes!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).popUntil((route) => route.isFirst); // Go back to the root screen
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void handleAnswer(String selectedAnswer) {
    setState(() {
      selectedOption = selectedAnswer; // Update selected option
      _isAnswered = true;
      _isCorrect = selectedAnswer == correctAnswer;

      // Handle the case when the last question is answered
      if (_currentWordIndex + 1 >= dataList.length) {
        // If this was the last question, show the dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCongratulationsDialog();
        });
      }
    });
  }

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      top: 40, // Position at the top
      right: 25, // Position from the right
      child: Container(
        width: 35,
        height: 35,
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: const Color.fromARGB(255, 67, 67, 67)),
          borderRadius: BorderRadius.circular(50),
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          iconSize: 15,
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context, List<dynamic> options) {
    return Column(
      children: options.map((option) {
        return _buildOption(context, option);
      }).toList(),
    );
  }

  Widget _buildOption(BuildContext context, String option) {
    final isSelected = selectedOption == option; // Check if this option is selected
    final isCorrectOption = option == correctAnswer; // Check if this option is correct

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          handleAnswer(option);
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 3 / 4,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? (isCorrectOption ? AppColors.correct : AppColors.wrong) // Green if correct, red if wrong
                : AppColors.accentColor, // Default color
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(
              option,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerTitle(BuildContext context, String title, String subcategoryTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Center(
        child: Column(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: AppFonts.fcr,
                color: AppColors.titleColor,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subcategoryTitle,
              style: const TextStyle(
                fontFamily: AppFonts.fcr,
                fontSize: 26,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageWithWordContainer(BuildContext context, String? imageUrl, String title) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _imageContainer(context, imageUrl),
        _wordContainer(context, title), // Place wordContainer at the bottom
      ],
    );
  }

  Widget _imageContainer(BuildContext context, String? imageUrl) {
    return Container(
      width: MediaQuery.of(context).size.width * 2.3 / 3,
      height: MediaQuery.of(context).size.height * 1 / 3,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: AppColors.accentColor,
      ),
      child: imageUrl != null && imageUrl.isNotEmpty
          ? Image.network(imageUrl, fit: BoxFit.cover) // Display image from network
          : const Center(child: Text('No image available')), // Placeholder text or widget
    );
  }

  Widget _wordContainer(BuildContext context, String title) {
    return SizedBox(
      height: 70,
      child: Center(
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.titleColor,
          ),
        ),
      ),
    );
  }

  Widget _notifText() {
    return const Text(
      'Select the correct translation:',
      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
    );
  }
}
