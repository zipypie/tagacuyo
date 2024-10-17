import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:taga_cuyo/src/features/common_widgets/custom_alert_dialog.dart';
import 'package:taga_cuyo/src/features/constants/colors.dart';
import 'package:taga_cuyo/src/features/constants/fontstyles.dart';
import 'package:taga_cuyo/src/features/services/submit_ticket.dart';

class SupportTicketForm extends StatefulWidget {
  const SupportTicketForm({super.key});

  @override
  State<SupportTicketForm> createState() => _SupportTicketFormState();
}

class _SupportTicketFormState extends State<SupportTicketForm> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _issueController = TextEditingController();

  final SupportTicketService _supportTicketService = SupportTicketService();
  bool _isSubmitting = false;
  File? _selectedImage; // To store the selected image

  final ImagePicker _picker = ImagePicker();

  // Method to pick an image from gallery or camera
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  // Method to validate email format
  bool _isValidEmail(String email) {
    String emailPattern =
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'; // Basic email regex pattern
    RegExp regex = RegExp(emailPattern);
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit a Ticket', style: TextStyle(fontFamily: AppFonts.fcb, fontSize: 24)),
        backgroundColor: AppColors.primary,
        elevation: 2.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Kailangan ng tulong? ",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.titleColor,
                ),
              ),
              SizedBox(height: 30),
              Text(
                "Punan lamang ang form sa ibaba para magsumite ng ticket, at babalikan ka ng aming team ng suporta sa lalong madaling panahon.",
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
              SizedBox(height: 30),

              // Name Field
              _buildTextField(_nameController, 'Buong Pangalan'),

              // Email Field
              _buildTextField(_emailController, 'Email Address'),

              // Issue Description Field
              _buildTextField(_issueController, 'Ilarawan ang iyong isyu sa app', maxLines: 6),

              SizedBox(height: 20),

              // Image Picker Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Add Image:", style: TextStyle(fontSize: 16)),
                  IconButton(
                    icon: Icon(Icons.add_a_photo, color: AppColors.primary),
                    onPressed: _pickImage,
                  ),
                ],
              ),

              // Display the selected image
              if (_selectedImage != null)
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: FileImage(_selectedImage!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

              SizedBox(height: 30),

              // Submit Button
              Center(
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      foregroundColor: AppColors.primaryBackground,
                      backgroundColor: AppColors.primary,
                    ),
                    child: _isSubmitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: AppColors.primaryBackground,
                              ),
                              SizedBox(width: 10),
                              Text('Submitting...'),
                            ],
                          )
                        : const Text('Isumite', style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 16),
          contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  void _handleSubmit() async {
  setState(() {
    _isSubmitting = true; // Set loading state to true
  });

  String name = _nameController.text.trim();
  String email = _emailController.text.trim();
  String issue = _issueController.text.trim();

  // Validate fields
  if (name.isEmpty) {
    showCustomAlertDialog(
      context,
      'Kulang na Impormasyon',
      'Mangyaring ilagay ang iyong buong pangalan.',
    );
    setState(() {
      _isSubmitting = false; // Reset loading state
    });
    return; // Stop execution if name is empty
  }

  if (email.isEmpty) {
    showCustomAlertDialog(
      context,
      'Kulang na Impormasyon',
      'Mangyaring ilagay ang iyong email address.',
    );
    setState(() {
      _isSubmitting = false; // Reset loading state
    });
    return; // Stop execution if email is empty
  }

  if (issue.isEmpty) {
    showCustomAlertDialog(
      context,
      'Kulang na Impormasyon',
      'Mangyaring ilarawan ang iyong isyu.',
    );
    setState(() {
      _isSubmitting = false; // Reset loading state
    });
    return; // Stop execution if issue is empty
  }

  // Validate email format
  if (!_isValidEmail(email)) {
    showCustomAlertDialog(
      context,
      'Invalid Email',
      'Mangyaring ilagay ang isang wastong email address.',
    );
    setState(() {
      _isSubmitting = false; // Reset loading state
    });
    return; // Stop execution if email is invalid
  }

  try {
    // Call the service to submit the ticket
    await _supportTicketService.submitTicket(name, email, issue, _selectedImage);

    // Show success dialog if submission is successful
    showCustomAlertDialog(
      context,
      'Naisumite na ang Ticket',
      'Matagumpay na naisumite ang iyong ticket sa aming support. Makikipag-ugnayan sa iyo ang aming ahente sa lalong madaling panahon.',
    );

    // Clear the fields after successful submission
    _nameController.clear();
    _emailController.clear();
    _issueController.clear();
    setState(() {
      _selectedImage = null;
    });
  } catch (e) {
    // Show error dialog if submission fails
    showCustomAlertDialog(
      context,
      'Error',
      'Nangyari ang isang error sa pagsumite ng iyong ticket: ${e.toString()}',
    );
  } finally {
    setState(() {
      _isSubmitting = false; // Reset loading state
    });
  }
}

}
