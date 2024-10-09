import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taga_cuyo/src/features/common_widgets/button.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/services/profile_service.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfileScreen> {
  final ProfileService profileService = ProfileService();
  final ImagePicker _picker = ImagePicker();
  XFile? _image; // For storing selected image

  final TextEditingController firstnameController = TextEditingController();
  final TextEditingController lastnameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController genderController = TextEditingController();
  final TextEditingController ageController = TextEditingController();

  // Individual variables to track editable states for each field
  bool _isFirstnameEditable = false;
  bool _isLastnameEditable = false;
  bool _isEmailEditable = false;
  bool _isGenderEditable = false;
  bool _isAgeEditable = false;

  // Local variable to track user data
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData(); // Fetch user data on initialization
  }

  Future<void> _fetchUserData() async {
    DocumentSnapshot snapshot = await ProfileService.currentUser().first;
    if (snapshot.exists) {
      userData = snapshot.data() as Map<String, dynamic>;
      firstnameController.text = userData!['firstname'] ?? '';
      lastnameController.text = userData!['lastname'] ?? '';
      emailController.text = userData!['email'] ?? '';
      genderController.text = userData!['gender'] ?? '';
      ageController.text = userData!['age']?.toString() ?? '0';
      // You can log the profile image URL to debug
      setState(() {}); // Rebuild the widget to display the data
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppColors.primary,
        elevation: 0,
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Image
                  // Profile Image
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: _image != null
                            ? FileImage(File(_image!.path))
                            : (userData?['profile_image'] != null &&
                                    userData!['profile_image'].isNotEmpty
                                ? NetworkImage(userData!['profile_image'])
                                : null),
                        // If both _image and userData['profile_image'] are null, set a placeholder image
                        child: _image == null &&
                                (userData?['profile_image'] == null ||
                                    userData!['profile_image'].isEmpty)
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Firstname
                  _buildTextField(
                    icon: Icons.person,
                    controller: firstnameController,
                    isEditable: _isFirstnameEditable,
                    onEditTap: () {
                      setState(() {
                        _isFirstnameEditable =
                            !_isFirstnameEditable; // Toggle editable state for firstname
                      });
                    },
                    labelText: 'First Name',
                  ),
                  const Divider(),

                  // Lastname
                  _buildTextField(
                    icon: Icons.person,
                    controller: lastnameController,
                    isEditable: _isLastnameEditable,
                    onEditTap: () {
                      setState(() {
                        _isLastnameEditable =
                            !_isLastnameEditable; // Toggle editable state for lastname
                      });
                    },
                    labelText: 'Last Name',
                  ),
                  const Divider(),

                  // Email
                  _buildTextField(
                    icon: Icons.email,
                    controller: emailController,
                    isEditable: _isEmailEditable,
                    onEditTap: () {
                      setState(() {
                        _isEmailEditable =
                            !_isEmailEditable; // Toggle editable state for email
                      });
                    },
                    labelText: 'Email',
                  ),
                  const Divider(),

                  // Gender
                  _buildTextField(
                    icon: Icons.person_outline,
                    controller: genderController,
                    isEditable: _isGenderEditable,
                    onEditTap: () {
                      setState(() {
                        _isGenderEditable =
                            !_isGenderEditable; // Toggle editable state for gender
                      });
                    },
                    labelText: 'Gender',
                  ),
                  const Divider(),

                  // Age
                  _buildTextField(
                    icon: Icons.cake,
                    controller: ageController,
                    isEditable: _isAgeEditable,
                    onEditTap: () {
                      setState(() {
                        _isAgeEditable =
                            !_isAgeEditable; // Toggle editable state for age
                      });
                    },
                    labelText: 'Age',
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 24),

                  // Update button
                  MyButton(
                    onTab: (_image != null ||
                            _isFirstnameEditable ||
                            _isLastnameEditable ||
                            _isEmailEditable ||
                            _isGenderEditable ||
                            _isAgeEditable)
                        ? _updateProfile
                        : () {}, // No-op function for disabled state
                    text: 'Update Profile',
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildTextField({
    required IconData icon,
    required TextEditingController controller,
    required bool isEditable,
    required VoidCallback onEditTap,
    required String labelText,
    TextInputType? keyboardType,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: TextField(
        controller: controller,
        enabled: isEditable, // Control editing
        decoration: InputDecoration(
          labelText: labelText,
          border: InputBorder.none,
        ),
        keyboardType: keyboardType,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.edit),
        onPressed: onEditTap,
      ),
    );
  }

  // Function to pick image from gallery or camera
// Function to pick image from gallery or camera
  Future<void> _pickImage() async {
    final pickedImage = await showDialog<XFile>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose an option'),
          content: const Text('Select a source to upload your profile image.'),
          actions: [
            TextButton(
              child: const Text('Camera'),
              onPressed: () async {
                final image =
                    await _picker.pickImage(source: ImageSource.camera);
                Navigator.of(context).pop(image); // Return the selected image
              },
            ),
            TextButton(
              child: const Text('Gallery'),
              onPressed: () async {
                final image =
                    await _picker.pickImage(source: ImageSource.gallery);
                Navigator.of(context).pop(image); // Return the selected image
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context)
                    .pop(); // Close dialog without returning an image
              },
            ),
          ],
        );
      },
    );

    // Update the state with the selected image
    if (pickedImage != null) {
      setState(() {
        _image = pickedImage; // Update the image state
      });
    }
  }

  // Example function to update the profile
 void _updateProfile() async {
  String firstname = firstnameController.text;
  String lastname = lastnameController.text;
  int age = int.tryParse(ageController.text) ?? 0; // Ensure valid integer input
  String gender = genderController.text;

  try {
    String? profileImageUrl; // Variable to hold the uploaded image URL

    if (_image != null) {
      // Upload the image to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('profile_images/${DateTime.now().millisecondsSinceEpoch}.jpg');

      // Upload the file
      await imageRef.putFile(File(_image!.path));

      // Get the download URL
      profileImageUrl = await imageRef.getDownloadURL();
    }

    // Now, update the Firestore document with the new profile data
    await profileService.updateUserProfile(
      firstname: firstname,
      lastname: lastname,
      age: age,
      gender: gender,
      profileImage: profileImageUrl, // Use the new image URL
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile updated successfully')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update failed: $e')),
    );
  }
}

}
