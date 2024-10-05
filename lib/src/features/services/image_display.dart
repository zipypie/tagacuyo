import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FireStoreImageDisplay extends StatefulWidget {
  const FireStoreImageDisplay({super.key});

  @override
  State<FireStoreImageDisplay> createState() => _FireStoreImageDisplayState();
}

class _FireStoreImageDisplayState extends State<FireStoreImageDisplay> {
  String? imageUrl;
  final storage = FirebaseStorage.instance;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _loadImage(); // Load the image when the widget is initialized
  }

  Future<void> _loadImage() async {
    try {
      // Replace 'your_image_path' with the actual path of your image in Firebase Storage
      String downloadUrl = await storage.ref('your_image_path').getDownloadURL();
      setState(() {
        imageUrl = downloadUrl;
        isLoading = false;
      });
    } catch (e) {
      // If an error occurs, set hasError to true
      setState(() {
        hasError = true;
        isLoading = false;
      });
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FireStore Image Display'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator() // Show a loading indicator while the image is loading
            : hasError
                ? const Text('Failed to load image') // Show error message on failure
                : imageUrl != null
                    ? Image.network(imageUrl!) // Display the image once loaded
                    : const Text('No image found'), // Handle case if imageUrl is null
      ),
    );
  }
}
