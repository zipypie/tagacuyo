import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';

class CategoryQuizScreen extends StatefulWidget {
  const CategoryQuizScreen({super.key});

  @override
  State<CategoryQuizScreen> createState() => _CategoryQuizScreenState();
}

class _CategoryQuizScreenState extends State<CategoryQuizScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Stack(
          children: [
            // Title and subtitle in the center
            Column(
              children: [
                _headerTitle(context),
                SizedBox(height: 20),
                _notifText(),
                _imageContainer(context), // Now correctly returns a widget
              ],
            ),
            // Close button positioned in the top-right corner
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    width: 0.5,
                  ),
                ),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context); // Go back to the previous screen
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _notifText() {
  return SizedBox(
    child: Text('i-click ang imahe para sa audio', style: TextStyle(
      fontStyle: FontStyle.italic,
      fontFamily: AppFonts.fcr,
      fontSize: 14
    ),),
  );
}

Widget _headerTitle(BuildContext context) {
  return const Padding(
    padding: EdgeInsets.only(top: 30),
    child: Center(
      child: Column(
        children: [
          Text(
            'title category',
            style: TextStyle(
              fontFamily: AppFonts.fcr,
              color: AppColors.titleColor,
              fontSize: 18,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'subtitle category',
            style: TextStyle(
              fontFamily: AppFonts.fcr,
              fontSize: 24,
              color: Colors.black,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _imageContainer(BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width * 2 / 3,
    height: MediaQuery.of(context).size.height * 1 / 4,
    decoration: BoxDecoration(
      borderRadius: const BorderRadius.all(Radius.circular(25)),
      border: Border.all(
        width: 2,
        color: Colors.amber,
      ),
    ),

    child: Image.asset('assets/images/tagacuyo_logo.png'),
  );
}
