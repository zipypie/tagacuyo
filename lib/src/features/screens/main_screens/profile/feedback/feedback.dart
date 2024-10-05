// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

class FeedbackScreen extends StatefulWidget {
  const FeedbackScreen({super.key});

  @override
  FeedbackScreenState createState() => FeedbackScreenState();
}

class FeedbackScreenState extends State<FeedbackScreen> {
  int _rating = 0;
  List<bool> _selectedOptions = [false, false, false, false];
  final TextEditingController _commentController = TextEditingController();

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Padding(
          padding: EdgeInsets.only(top: 25), // Same padding for top and bottom
          child: Text(
            'Ibahagi ang iyong Katugunan',
            style: TextStyle(fontSize: 24, fontFamily: AppFonts.lilitaOne),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.only(top: 25),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Handle back button press
              Navigator.pop(context);
            },
          ),
        ),
      ),
      body: SingleChildScrollView(
        // <-- Added SingleChildScrollView here
        padding: const EdgeInsets.all(40.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'I-rate ang iyong karanasan',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Star rating row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    _rating > index ? Icons.star : Icons.star_border,
                    color: Colors.yellow,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            // Star rating labels
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                return Text('${index + 1} bituin');
              }),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ano ang iyong nagustuhan?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            // Custom options with check.png icon
            _buildCustomOption(
              title: 'User Interface at Disenyo',
              index: 0,
            ),
            _buildCustomOption(
              title: 'Madaling Nabigasyon',
              index: 1,
            ),
            _buildCustomOption(
              title: 'Nilalaman at Mga Tampok',
              index: 2,
            ),
            _buildCustomOption(
              title: 'Karanasan sa Pagkatuto',
              index: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              'Ang iyong mga komento o mungkahi (opsyonal)',
              style: TextStyle(fontSize: 16),
            ),
            // Text input for additional comments
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Ilarawan ang iyong karanasan dito.',
                border: OutlineInputBorder(),
              ),
              maxLines: 7 ,
            ),
            const SizedBox(height: 20),
            // Submit button
            Center(
              child: MyButton(
                onTab: () async {
                  await _submitFeedback();
                },
                text: 'Isumite',
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Custom widget to display a rounded checkbox with a green background when checked
  Widget _buildCustomOption({required String title, required int index}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedOptions[index] = !_selectedOptions[index];
        });
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color:
                  _selectedOptions[index] ? Colors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: _selectedOptions[index] ? Colors.green : Colors.grey,
                width: 2,
              ),
            ),
            child: _selectedOptions[index]
                ? const Icon(
                    Icons.check,
                    color: Colors.white,
                  )
                : null, // Show only if selected
          ),
        ],
      ),
    );
  }

  // Method to submit feedback to Firestore
  Future<void> _submitFeedback() async {
    try {
      // Prepare the data to be submitted
      Map<String, dynamic> feedbackData = {
        'rating': _rating,
        'selectedOptions': {
          'ui_design': _selectedOptions[0],
          'easy_navigation': _selectedOptions[1],
          'content_features': _selectedOptions[2],
          'learning_experience': _selectedOptions[3],
        },
        'comments': _commentController.text,
        'timestamp':
            FieldValue.serverTimestamp(), // Store the time of submission
      };

      // Send the data to Firestore (assuming you have a 'feedback' collection)
      await _firestore.collection('feedback').add(feedbackData);

      // Optionally show a confirmation message or redirect the user
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Matamang salamat sa imong tugon!')),
      );

      // Clear the form after submission
      setState(() {
        _rating = 0;
        _selectedOptions = [false, false, false, false];
        _commentController.clear();
      });
    } catch (e) {
      // Handle error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error submitting feedback: $e')),
      );
    }
  }
}
