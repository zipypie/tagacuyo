// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/common_widgets/custom_alert_dialog.dart';
import 'package:taga_cuyo/src/features/common_widgets/text_input.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taga_cuyo/src/features/constants/logo.dart';
import 'package:taga_cuyo/src/features/screens/onboarding_screens/login/login.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;
  String emailError = '';

  // Function to send password reset email and check if the email is registered
  Future<void> sendPasswordResetEmail(BuildContext context) async {
    if (emailController.text.isEmpty) {
      setState(() {
        emailError = 'Pakilagay ang iyong email.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      emailError = ''; // Clear any previous errors
    });

    try {
      // Try sending password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text,
      );
      showCustomAlertDialog(context, 'Matagumpay','Naipadala na sa iyong email ang link sa pag-reset ng password.');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        // If no account exists, show an error message
        setState(() {
          emailError = 'Ang account na ito ay hindi registered';
        });
      } else {
        // Handle other errors
        setState(() {
          emailError = 'Error: ${e.message}';
        });
      }
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView( // Wrap the entire content in SingleChildScrollView
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: height / 3,
                child: LogoImage.logo,
              ),
              Container(
                margin: const EdgeInsets.all(30),
                child: const Center(
                  child: Text(
                    'Maligayang Pagdating sa Taga-Cuyo: Tagalog-Cuyonon isang Pagsasalin at Pag-aaral gamit ang Aplikasyon',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      letterSpacing: 1,
                      fontFamily: AppFonts.kanitLight,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              Container(
                height: height / 2.025,
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryBackground,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(15),
                      child: const Center(
                        child: Text(
                          'Nakalimutan ang password?',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            fontFamily: AppFonts.kanitLight,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextFieldInputF(
                      textEditingController: emailController,
                      hintText: "Ilagay ang iyong E-mail",
                      icon: Icons.email,
                      errorText: emailError.isNotEmpty ? emailError : null,
                    ),
                    const SizedBox(height: 15),
                    MyButton(
                      onTab: () => sendPasswordResetEmail(context), // Pass context here
                      text: "Magpadala ng link sa E-mail",
                    ),
                    if (isLoading)
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(),
                      ),
                    const SizedBox(height: 45),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Mayroon ng account? Piliin ang',
                          style: TextStyle(fontSize: 12),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigate to SignInScreen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignInScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            ' Login',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
