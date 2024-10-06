import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Import Firebase Storage
import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/constants/capitalize.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart';

class CategoryQuizScreen extends StatefulWidget {
  final String categoryId;
  final String subcategoryTitle;
  final String subcategoryId;
  final String currentWord;
  final String userId;

  const CategoryQuizScreen({
    super.key,
    required this.categoryId,
    required this.subcategoryTitle,
    required this.currentWord,
    required this.userId, 
    required this.subcategoryId,
  });

  @override
  State<CategoryQuizScreen> createState() => _CategoryQuizScreenState();
}

class _CategoryQuizScreenState extends State<CategoryQuizScreen> {
  bool _isCorrect = false;
  bool _isAnswered = false;
  String correctAnswer = '';
  List<dynamic> options = [];
  String? selectedOption;
  int _currentWordIndex = 0;
  List<Map<String, dynamic>> dataList = [];

  @override
  void initState() {
    super.initState();
    fetchCategorySubcategoryData();
  }

  @override
  Widget build(BuildContext context) {
    Logger.log('Current dataList: $dataList'); 
    
    if (dataList.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // If all questions have been answered, show a message
    if (_currentWordIndex >= dataList.length) {
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
                // Fetch the image URL here
                FutureBuilder<String>(
                  future: fetchImageFromStorage(data['image_path']),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return const Center(child: Text('Error loading image.'));
                    } else {
                      return _imageWithWordContainer(context, snapshot.data, data['word']);
                    }
                  },
                ),
                const SizedBox(height: 20),
                _notifText(),
                const SizedBox(height: 20),
                _buildOptions(context, options),
                if (_isAnswered && !_isCorrect)
                  const Padding(
                    padding: EdgeInsets.only(top: 20),
                    child: Text(
                      'Ulitin muli',
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
                    text: 'Sunod',
                  ),
              ],
            ),
          ),
          _buildCloseButton(context),
        ],
      ),
    );
  }



Future<void> fetchCategorySubcategoryData() async {
  try {
    Logger.log('Fetching data for Category ID: ${widget.categoryId}, Subcategory Title: ${widget.subcategoryTitle}');
    
    var snapshot = await FirebaseFirestore.instance
        .collection('categories')
        .doc(widget.categoryId)
        .collection('subcategories')
        .doc(widget.subcategoryId)
        .collection('words')
        .get();

    Logger.log('Fetched ${snapshot.docs.length} words'); // Log the number of documents fetched
    if (snapshot.docs.isNotEmpty) {
      for (var doc in snapshot.docs) {
        Logger.log('Fetched word: ${doc.data()}'); // Log each fetched word
      }

      setState(() {
        dataList = snapshot.docs.map((doc) => doc.data()).toList();
        _currentWordIndex = 0; // Reset index
      });
    } else {
      Logger.log('No words found for this subcategory.');
      _showCongratulationsDialog(); // Consider handling this more gracefully
    }
  } catch (e) {
    Logger.log('Error fetching Category subcategory data: $e');
  }
}


  Future<String> fetchImageFromStorage(String imagePath) async {
    try {
      Reference imageRef = FirebaseStorage.instance.refFromURL(imagePath);
      return await imageRef.getDownloadURL();
    } catch (e) {
      Logger.log("Error fetching image from storage: $e");
      return '';
    }
  }

  void _showCongratulationsDialog() async {
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

      if (_isCorrect && _currentWordIndex + 1 >= dataList.length) {
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
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () {
          handleAnswer(option);
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 3 / 4,
          height: 40,
          decoration: BoxDecoration(
            color: isSelected ? (isCorrectOption ? AppColors.correct : AppColors.wrong) : AppColors.accentColor,
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
              capitalizeFirstLetter(categoryId),
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
        _wordContainer(context, word),
      ],
    );
  }

  Widget _imageContainer(BuildContext context, String? imageUrl) {
    return Container(
      width: MediaQuery.of(context).size.width * 2.3 / 3,
      height: MediaQuery.of(context).size.height * 1 / 3,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(25)),
        color: const Color.fromARGB(150, 255, 255, 255), // Semi-transparent background
        border: Border.all(
          color: const Color.fromARGB(255, 100, 142, 190), // Border color
          width: 5, // Adjust the width of the border if needed
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(25),
        child: imageUrl != null && imageUrl.isNotEmpty
            ? Image.network(imageUrl, fit: BoxFit.cover)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _wordContainer(BuildContext context, String word) {
  return Positioned(
    bottom: 0,
    child: Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(25)),
        color: Color.fromARGB(150, 255, 255, 255), // Set opacity here (0-255)
      ),
      padding: const EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width * 2.3 / 3,
      child: Center(
        child: Text(
          word,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: AppFonts.fcr,
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.titleColor,
          ),
        ),
      ),
    ),
  );
}



  Widget _notifText() {
    return Container(
      height: 50,
      width: MediaQuery.of(context).size.width * 0.8,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: _isAnswered && _isCorrect ? AppColors.correct : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: _isAnswered && _isCorrect
            ? const Text(
                'Tama ang iyong sagot!',
                style: TextStyle(fontFamily: AppFonts.fcr, fontSize: 21, color: Color.fromARGB(255, 0, 0, 0)),
              )
            : const Text(''),
      ),
    );
  }
}
