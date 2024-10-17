import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:taga_cuyo/src/features/services/authentication.dart';
import 'package:taga_cuyo/src/features/utils/logger.dart'; // Import AuthService

class SupportTicketService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AuthService _authService = AuthService(); // Create an instance of AuthService

  // Method to submit a support ticket
 Future<void> submitTicket(String name, String email, String issue, File? image) async {
    String? imageUrl;

    // Upload the image to Firebase Storage if it exists
    if (image != null) {
        // Create a unique file name
        String fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
        try {
            await _storage.ref('tickets/$fileName').putFile(image);
            imageUrl = await _storage.ref('tickets/$fileName').getDownloadURL();
        } catch (e) {
            Logger.log('Error uploading image: $e');
            // Optionally handle the image upload failure (e.g., skip the upload)
        }
    }

    // Get the current user's UID
    String? userId = _authService.getUserId(); // Get UID from AuthService
    if (userId == null) {
        throw Exception('User is not authenticated'); // Handle this case appropriately
    }

    // Prepare the ticket data
    Map<String, dynamic> ticketData = {
        'name': name,
        'email': email,
        'issue': issue,
        'imageUrl': imageUrl,
        'submittedAt': FieldValue.serverTimestamp(),
        'userId': userId, // Add the UID to the ticket data
    };

    // Submit the ticket data to Firestore
    try {
        Logger.log('Submitting ticket data: $ticketData');
        await _firestore.collection('tickets').add(ticketData);
    } catch (e) {
        Logger.log('Error submitting ticket: ${e.toString()}');
        throw Exception('Failed to submit ticket');
    }
}

}
