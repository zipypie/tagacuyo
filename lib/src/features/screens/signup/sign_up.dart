import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/common_widgets/dropdown_input.dart';
import 'package:taga_cuyo/src/features/common_widgets/snack_bar.dart';
import 'package:taga_cuyo/src/features/common_widgets/text_input.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/screens/login/login.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';

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
  String? selectedGender; // Variable to store selected gender
  bool isLoading = false;

  void signUpUser() async {
    // Ensure all fields are filled
    if (firstnameController.text.isEmpty ||
        lastnameController.text.isEmpty ||
        emailController.text.isEmpty ||
        passwordController.text.isEmpty ||
        ageController.text.isEmpty ||
        selectedGender == null) {
      showSnackBar(context, "Pakipunan ang lahat ng form");
      return;
    }

    // Sign up the user using the AuthServicews
    String res = await AuthService().signUpUser(
      firstname: firstnameController.text,
      lastname: lastnameController.text,
      email: emailController.text,
      password: passwordController.text,
      age: ageController.text,
      gender: selectedGender!,
    );

    // Handle the result
    if (res == "Success") {
      setState(() {
        isLoading = true;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      });
    } else {
      setState(() {
        isLoading = false;
        showSnackBar(context, res);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.primaryBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: double.infinity,
                height: height / 3.5,
                child: Image.asset('assets/icons/tagacuyo_logo.png'),
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
              Container(
                height: height / 1.65,
                padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
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
                    MyButton(onTab: signUpUser, text: "Isumite"),
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
                            ' Login',
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
