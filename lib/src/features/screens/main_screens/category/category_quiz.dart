import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/constants/capitalize.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/services/category_service.dart';

class NextQuizScreen extends StatefulWidget {
  final String categoryId; // Add this line
  final String subcategoryTitle;
  final String currentWord;
  final String userId;

  const NextQuizScreen({
    Key? key,
    required this.categoryId, // Add 'required' parameter
    required this.subcategoryTitle,
    required this.currentWord,
    required this.userId,
  }) : super(key: key);


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
  final CategoryProgressService _categoryProgressService =
      CategoryProgressService(); // Create an instance

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
  correctAnswer = data['translated'];
  options = data['options'];

  return Scaffold(
    body: Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              _headerTitle(context, widget.categoryId, widget.subcategoryTitle),
              const SizedBox(height: 20),
              _imageWithWordContainer(context, data['image'], data['word']),
              const SizedBox(height: 20),
            
              _notifText(), // Always occupy space
              
              const SizedBox(height: 20),
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
        _buildCloseButton(context),
      ],
    ),
  );
}


  Future<void> fetchNextSubcategoryData() async {
    try {
      var snapshot = await FirebaseFirestore.instance
          .collection('categories')
          .doc(widget.categoryId) // Use categoryId instead of title
          .collection('subcategories')
          .doc(widget.subcategoryTitle)
          .collection('words')
          .where('word', isGreaterThan: widget.currentWord)
          .get();

      if (snapshot.docs.isNotEmpty) {
        setState(() {
          dataList = snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();
        });
      } else {
        _showCongratulationsDialog();
      }
    } catch (e) {
      print('Error fetching next subcategory data: $e');
    }
  }

  void _showCongratulationsDialog() async {
     _categoryProgressService.createCategoryProgress(
        widget.userId, widget.categoryId); // Use categoryId here
    print('Created category progress for ${widget.categoryId}');
     _categoryProgressService.markSubcategoryAsCompleted(
        widget.userId, widget.categoryId, widget.subcategoryTitle);
     _categoryProgressService.incrementCompletedCategories(widget.userId);
    print('Incremented completed categories for user ${widget.userId}');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Congratulations!'),
          content: const Text('You have completed all the quizzes!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
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
      selectedOption = selectedAnswer;
      _isAnswered = true;
      _isCorrect = selectedAnswer == correctAnswer;

      if (_currentWordIndex + 1 >= dataList.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _showCongratulationsDialog();
        });
      }
    });
  }

  Widget _buildCloseButton(BuildContext context) {
    return Positioned(
      top: 40,
      right: 25,
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
    final isSelected = selectedOption == option;
    final isCorrectOption = option == correctAnswer;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8,),
      child: GestureDetector(
        onTap: () {
          handleAnswer(option);
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 3 / 4,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected
                ? (isCorrectOption ? AppColors.correct : AppColors.wrong)
                : AppColors.accentColor,
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

  Widget _headerTitle(BuildContext context, String categoryId, String subcategoryTitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 30),
      child: Center(
        child: Column(
          children: [
            Text(
              capitalizeFirstLetter(categoryId), // Display the category ID here
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
  Widget _imageWithWordContainer(BuildContext context, String? imageUrl, String word) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        _imageContainer(context, imageUrl),
        _wordContainer(context, word), // Display the word here
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: imageUrl != null
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
              )
            : const Center(child: Text('Image not available')),
      ),
    );
  }

  Widget _wordContainer(BuildContext context, String title) {
    return Positioned(
      bottom: 20,
      child: Container(
        height: 50,
        width: 170,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(40),
          color: Colors.white.withOpacity(0.8),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: AppFonts.fcr,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }
Widget _notifText() {
  // Reserve space for the notification text
  return Container(
    height: 50, // Fixed height for notification space
    width: MediaQuery.of(context).size.width * 0.8,
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    decoration: BoxDecoration(
      color: _isAnswered && _isCorrect ? AppColors.correct : Colors.transparent,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Center(
      child: _isAnswered && _isCorrect 
        ? const Text(
            'Correct!',
            style: TextStyle(fontSize: 20, color: Colors.white),
          )
        : const SizedBox.shrink(), // Return empty space if not correct
    ),
  );
}

}