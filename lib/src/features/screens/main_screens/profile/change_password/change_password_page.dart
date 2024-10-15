import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taga_cuyo/src/features/common_widgets/custom_alert_dialog.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ChangePasswordScreenState createState() => ChangePasswordScreenState();
}

class ChangePasswordScreenState extends State<ChangePasswordScreen>
    with SingleTickerProviderStateMixin {
  User? _user;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _currentPasswordController =
      TextEditingController();
  bool _isEditing = false; // Track if editing mode is active
  bool _isCurrentPasswordVisible = false; // Track visibility of current password
  bool _isNewPasswordVisible = false; // Track visibility of new password
  bool _isConfirmPasswordVisible = false; // Track visibility of confirm password
  final _animationDuration = const Duration(milliseconds: 300); // Duration for the animations

  @override
  void initState() {
    super.initState();
    _user = FirebaseAuth.instance.currentUser;
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _currentPasswordController.dispose();
    super.dispose();
  }

Future<void> _saveUserData() async {
  if (_user != null) {
    try {
      // Check if the new password and confirm password match
      if (_newPasswordController.text != _confirmPasswordController.text) {
        await showCustomAlertDialog(
          context,
          'Maling Password', // Title for the dialog
          'Ang bagong password ay hindi nagtutugma.', // Content for the dialog
          buttonText: 'Ayos', // Button text
        );
        return;
      }

      AuthCredential credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: _currentPasswordController.text,
      );

      // Attempt to reauthenticate
      await _user!.reauthenticateWithCredential(credential);

      // Update password
      await _user!.updatePassword(_newPasswordController.text);
      await showCustomAlertDialog(
        context,
        'Success', // Title for the dialog
        'Ang password ay na-update nang matagumpay!', // Content for the dialog
        buttonText: 'Ayos', // Button text
      );
    } catch (e) {
      await showCustomAlertDialog(
        context,
        'Error', // Title for the dialog
        'Nabigong i-update ang password: $e', // Content for the dialog
        buttonText: 'Ayos', // Button text
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        title: const Text('Magpalit ng Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(30.0, 30.0, 30.0, 30.0),
        child: SingleChildScrollView(
          // Enables scrolling when the keyboard appears
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildAnimatedPasswordField(
                  "Kasalukuyang password",
                  _currentPasswordController,
                  _isCurrentPasswordVisible, (value) {
                setState(() {
                  _isCurrentPasswordVisible = value;
                });
              }),
              const SizedBox(height: 20),
              _buildAnimatedPasswordField(
                  "Bagong password",
                  _newPasswordController,
                  _isNewPasswordVisible, (value) {
                setState(() {
                  _isNewPasswordVisible = value;
                });
              }),
              const SizedBox(height: 20),
              _buildAnimatedPasswordField(
                  "Kumpirmahin ang bagong password",
                  _confirmPasswordController,
                  _isConfirmPasswordVisible, (value) {
                setState(() {
                  _isConfirmPasswordVisible = value;
                });
              }),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(top: 25.0),
                child: Center(
                  child: AnimatedScale(
                    scale: _isEditing ? 1.05 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      ),
                      onPressed: _isEditing
                          ? _saveUserData
                          : () {
                              setState(() {
                                _isEditing = true; // Allow editing mode after the first button click
                              });
                            },
                      child: const Text("Isumite"),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedPasswordField(
      String label, TextEditingController controller, bool isVisible, Function(bool) onToggle) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: AnimatedContainer(
        duration: _animationDuration,
        curve: Curves.easeInOut,
        height: 60, // Fixed height for the text field
        child: TextField(
          controller: controller,
          obscureText: !isVisible, // Show or hide password
          decoration: InputDecoration(
            labelText: label, // The label will float up
            labelStyle: const TextStyle(
              color: AppColors.titleColor,
            ),
            hintText: 'Ilagay ang $label',
            hintStyle: const TextStyle(color: Colors.grey), // Hint color
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.titleColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color.fromARGB(255, 147, 147, 147)),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: AppColors.titleColor,
              ),
              onPressed: () {
                onToggle(!isVisible); // Toggle visibility
              },
            ),
          ),
        ),
      ),
    );
  }
}
