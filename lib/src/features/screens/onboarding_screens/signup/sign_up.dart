import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/common_widgets/dropdown_input.dart';
import 'package:taga_cuyo/src/features/common_widgets/text_input.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/constants/logo.dart';
import 'package:taga_cuyo/src/features/screens/onboarding_screens/login/login.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/features/common_widgets/custom_alert_dialog.dart'; // Import your custom alert dialog

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String? selectedGender;
  bool isLoading = false;

  void signUpUser() async {
    // Ensure all fields are filled
    if (firstnameController.text.isEmpty ||
        lastnameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        ageController.text.isEmpty ||
        selectedGender == null) {
      await showCustomAlertDialog(
        context,
        'Error',
        'Pakipunan ang lahat ng form',
      );
      return;
    }

    setState(() {
      isLoading = true; // Show loading indicator
    });

    // Sign up the user using the AuthService
    String res = await AuthService().signUpUser(
      firstname: firstnameController.text,
      lastname: lastnameController.text,
      email: emailController.text,
      password: passwordController.text,
      age: int.parse(ageController.text),
      gender: selectedGender!,
    );

    setState(() {
      isLoading = false; // Hide loading indicator
    });

    // Handle the result
    if (res == "Success") {
      await showCustomAlertDialog(
        context,
        'Success',
        'Ang iyong account ay matagumpay na nalikha.',
        buttonText: 'OK',
      );

      // Navigate to SignInScreen after closing the dialog
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInScreen()),
      );
    } else {
      await showCustomAlertDialog(
        context,
        'Error',
        res,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.secondaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: AppColors.primaryBackground,
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: height / 3.5,
                      child: LogoImage.logo,
                    ),
                    const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Magrehistro',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 1,
                              fontFamily: AppFonts.kanitLight,
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Punan ang form na nasa ibaba',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              letterSpacing: 1,
                              fontFamily: AppFonts.kanitLight,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.fromLTRB(25, 15, 25, 15),
                decoration: const BoxDecoration(
                  color: AppColors.secondaryBackground,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFieldInputF(
                      textEditingController: firstnameController,
                      hintText: "Aran (Pangalan)",
                      icon: Icons.person,
                    ),
                    TextFieldInputF(
                      textEditingController: lastnameController,
                      hintText: "Apilido (Apelyido)",
                      icon: Icons.person,
                    ),
                    TextFieldInputF(
                      textEditingController: emailController,
                      hintText: "E-mail",
                      icon: Icons.email,
                    ),
                    TextFieldInputF(
                      textEditingController: passwordController,
                      hintText: "Password",
                      icon: Icons.lock,
                      isPass: true,
                    ),
                    TextFieldInputF(
                      textEditingController: ageController,
                      hintText: "Idad (Edad)",
                      icon: Icons.person_2_outlined,
                    ),
                    DropdownInputF(
                      value: selectedGender,
                      items: const ['Lalaki', 'Babae'],
                      hintText: "Pumili ng Kasarian",
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedGender = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    // Show loading indicator or button
                    isLoading
                        ? const CircularProgressIndicator() // Loading spinner
                        : MyButton(onTab: signUpUser, text: "Isumite"),
                    const SizedBox(height: 20),
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
                            ' Login.',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      ],
                    ),
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


