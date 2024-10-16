import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/constants/images.dart';
import 'package:taga_cuyo/src/features/screens/onboarding_screens/login/login.dart';

class GetStartedPage extends StatelessWidget {
  final String text;
  final void Function() onNext; // Callback function to handle next action
  final String buttonText;
  final String imagePath;
  final String titleText;

  const GetStartedPage({
    super.key,
    required this.text,
    required this.onNext,
    required this.buttonText,
    required this.imagePath,
    required this.titleText,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Container(
                  color: const Color.fromARGB(255, 255, 248, 248),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Using Flexible to adapt the image size
                      Flexible(
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover, // Ensures the image covers the space
                          width: double.infinity,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  color: AppColors.secondaryBackground,
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.1, // Responsive padding
                      vertical: MediaQuery.of(context).size.height * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          titleText,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            fontFamily: AppFonts.kanitLight,
                            color: AppColors.titleColor,
                            letterSpacing: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          text,
                          style: const TextStyle(
                            fontSize: 18,
                            fontFamily: AppFonts.kanitLight,
                            color: AppColors.titleColor,
                            letterSpacing: 1,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 50,
            right: 50,
            child: ElevatedButton(
              onPressed: onNext,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
              child: Text(
                buttonText,
                style: const TextStyle(color: AppColors.titleColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  GetStartedScreenState createState() => GetStartedScreenState();
}

class GetStartedScreenState extends State<GetStartedScreen> {
  int currentPage = 0;
  late PageController pageController;

  final List<Map<String, dynamic>> pages = [
    {
      'title': 'Mag-aral ng Wika',
      'text':
          'Tuklasin ang yaman ng mga wika at palawakin ang iyong kaalaman sa Tagalog at Cuyonon',
      'imagePath': LocalImages.getStarted1,
      'buttonText': 'Sunod na Pahina',
    },
    {
      'title': 'Agad na Isalin',
      'text':
          'Mabilis na isalin ang mga salita at parirala, para sa mas mahusay na komunikasyon!',
      'imagePath': LocalImages.getStarted2,
      'buttonText': 'Sunod na Pahina',
    },
    {
      'title': 'Subaybayan ang Iyong Pag-unlad',
      'text':
          'Subaybayan ang iyong progreso sa pag-aaral at makita ang iyong mga tagumpay!',
      'imagePath': LocalImages.getStarted3,
      'buttonText': 'Magsimula',
    },
  ];

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  void onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  void goToNextPage(BuildContext context) {
    if (currentPage < pages.length - 1) {
      setState(() {
        currentPage++;
      });
      pageController.animateToPage(currentPage,
          duration: const Duration(milliseconds: 300), curve: Curves.ease);
      onPageChanged(currentPage); // Manually call onPageChanged
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    }
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: pageController,
            itemCount: pages.length,
            onPageChanged: onPageChanged,
            itemBuilder: (context, index) {
              return GetStartedPage(
                titleText: pages[index]['title'],
                text: pages[index]['text'],
                onNext: () =>
                    goToNextPage(context), // Pass context to the method
                buttonText: pages[index]['buttonText'],
                imagePath: pages[index]['imagePath'],
              );
            },
          ),
          Positioned(
            bottom: 20,
            left: MediaQuery.of(context).size.width / 2 - 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pages.length, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
