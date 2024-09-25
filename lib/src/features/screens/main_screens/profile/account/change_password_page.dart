import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:taga_cuyo/src/features/common_widgets/text_input.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/services/user_service.dart';
// Ensure this path is correct

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  User? _user;
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final UserService _userService = UserService();
  bool _isEditing = false; // Track if editing mode is active

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
        if (_newPasswordController.text != _confirmPasswordController.text) {
          _showSnackBar('New passwords do not match.');
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
        _showSnackBar('Password updated successfully!');
      } catch (e) {
        _showSnackBar('Failed to update password: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: const Text('Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildPasswordField("Current Password", _currentPasswordController),
            const SizedBox(height: 20),
            _buildPasswordField("New Password", _newPasswordController),
            const SizedBox(height: 20),
            _buildPasswordField("Confirm New Password", _confirmPasswordController),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                ),
                onPressed: _isEditing ? _saveUserData : () {
                  setState(() {
                    _isEditing = true; // Allow editing mode after the first button click
                  });
                },
                child: Text("Isumite"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: TextFieldInputF(
        textEditingController: controller,
        isPass: true,
        hintText: label,
        icon: Icons.lock,
      ),
    );
  }
}
