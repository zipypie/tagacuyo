import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Import for File class
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/services/user_service.dart';
import 'password_dialog.dart'; // Import the password dialog

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  File? _selectedImage; // To store the selected image from the gallery
  User? _user;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final UserService _userService = UserService();
  bool _isEditing = false; // Track if editing mode is active

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    _user = FirebaseAuth.instance.currentUser;
    if (_user != null) {
      DocumentSnapshot? userDoc = await _userService.getUserById(_user!.uid);
      if (userDoc != null) {
        _emailController.text = userDoc['email'] ?? _user!.email!;
      }
    }
  }

  Future<void> _saveUserData() async {
    if (_user != null) {
      try {
        List<DocumentSnapshot> existingUsers = await _userService.searchUsersByEmail(_emailController.text);
        if (existingUsers.isNotEmpty && existingUsers[0].id != _user!.uid) {
          _showSnackBar('Email is already in use by another account.');
          return;
        }

        // Update email in Firebase Authentication
        await _user!.updateEmail(_emailController.text);

        // Update email in Firestore
        await _userService.updateUserEmail(_user!.uid, _emailController.text);

        if (_newPasswordController.text.isNotEmpty) {
          await _user!.updatePassword(_newPasswordController.text);
          _showSnackBar('Password updated successfully!');
        }

        _showSnackBar('Account updated successfully!');
      } catch (e) {
        _showSnackBar('Failed to update account: $e');
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _askForPassword() {
    showDialog(
      context: context,
      builder: (context) => PasswordDialog(onUpdate: (password) {
        _verifyPassword(password);
      }),
    );
  }

  Future<void> _verifyPassword(String password) async {
    if (password.isEmpty) {
      _showSnackBar('Please enter your current password.');
      return;
    }

    try {
      AuthCredential credential = EmailAuthProvider.credential(
        email: _user!.email!,
        password: password,
      );

      // Attempt to reauthenticate
      await _user!.reauthenticateWithCredential(credential);
      setState(() {
        _isEditing = true; // Allow editing if password is correct
      });
      _showSnackBar('Password verified. You can now edit your data.');
    } catch (e) {
      _showSnackBar('Incorrect password. Please try again.');
    }
  }

  // Function to select image from gallery
  Future<void> _pickImageFromGallery() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        title: Text('Account'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 30.0), // Added top and bottom padding
        child: _user == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProfilePicture(),
                  SizedBox(height: 20), // Added spacing between elements
                  _buildEditableField("E-mail", _emailController),
                  SizedBox(height: 10), // Added spacing between elements
                  _buildPasswordField("New Password", _newPasswordController),
                  SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                      ),
                      onPressed: _isEditing ? _saveUserData : _askForPassword,
                      child: Text(_isEditing ? "Save" : "Edit"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _selectedImage != null
                ? FileImage(_selectedImage!)
                : NetworkImage(_user?.photoURL ?? 'https://via.placeholder.com/150') as ImageProvider,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: IconButton(
              icon: Icon(Icons.camera_alt, color: Colors.grey),
              onPressed: _pickImageFromGallery, // Pick image from gallery
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          TextFormField(
            controller: controller,
            decoration: InputDecoration(
              enabled: _isEditing, // Allow editing only when _isEditing is true
              border: OutlineInputBorder(), // Added border for better visibility
              filled: true,
              fillColor: Colors.grey[200], // Light grey background
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          TextFormField(
            controller: controller,
            obscureText: true,
            enabled: _isEditing, // Enable editing only after the password is verified
            decoration: InputDecoration(
              hintText: '********',
              border: OutlineInputBorder(), // Added border for better visibility
              filled: true,
              fillColor: Colors.grey[200], // Light grey background
            ),
          ),
        ],
      ),
    );
  }
}
