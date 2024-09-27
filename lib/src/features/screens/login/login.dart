import 'package:flutter/material.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/common_widgets/snack_bar.dart';
import 'package:taga_cuyo/src/features/common_widgets/text_input.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/logo.dart';
import 'package:taga_cuyo/src/features/screens/forget_password/forget_password.dart';
import 'package:taga_cuyo/src/features/screens/main_screens/home/home_screen.dart';
import 'package:taga_cuyo/src/features/screens/signup/sign_up.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;

  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (snapshot.exists) {
        return snapshot.data() as Map<String, dynamic>?;
      } else {
        print("No user data found for UID: $uid");
        return null;
      }
    } catch (e) {
      print("Error fetching user data: $e");
      return null;
    }
  }

 void signInUser() async {
    // Ensure all fields are filled
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      showSnackBar(context, "Pakipunan ang lahat ng form");
      return;
    }

    setState(() {
      isLoading = true;
    });

    // Sign in the user using the AuthServicews
    Map<String, dynamic> res = await AuthService().signInUser(
      email: emailController.text,
      password: passwordController.text,
    );

    // Handle the result
    if (res['res'] == "Success" && res['uid'] != null) {
      String uid = res['uid'];
      Map<String, dynamic>? userData = await getUserData(uid); // Fetch user data from Firestore

      if (userData != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              uid: uid,
              userData: userData,
            ),
          ),
        );
      } else {
        showSnackBar(context, "Ang account ay hindi nakita");
      }
    } else {
      showSnackBar(context, res['res'] as String);
    }

    setState(() {
      isLoading = false;
    });
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
              height: height/2,
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
              decoration: const BoxDecoration(
                color: AppColors.secondaryBackground,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 5.0),
                    child: Text(
                      'Mag-log in',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: AppFonts.kanitLight,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextFieldInputF(
                    textEditingController: emailController,
                    hintText: "E-mail",
                    icon: Icons.email,
                  ),
                  const SizedBox(height: 10),
                  TextFieldInputF(
                    textEditingController: passwordController,
                    hintText: "Password",
                    icon: Icons.lock,
                    isPass: true,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          // Navigate to ForgetPasswordScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ForgetPasswordScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Nakalimutan ang password',
                          style: TextStyle(
                            fontFamily: AppFonts.kanitLight,
                            fontSize: 16,
                            color: Color.fromARGB(255, 47, 87, 234),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  MyButton(onTab: signInUser, text: "Mag-login"),
                  SizedBox(height: height / 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Wala pang account? Piliin ang',
                        style: TextStyle(fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigate to SignUpScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          ' SignUp',
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