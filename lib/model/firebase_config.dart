// ignore_for_file: avoid_print

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Save data
  Future<void> saveData(String topic, String description, {File? image}) async {
    try {
      final String id = _generateUniqueId();
      String? imageUrl;

      if (image != null) {
        imageUrl = await _uploadImage(id, image);
      }

      final Map<String, dynamic> newData = {
        'id': id,
        'topic': topic,
        'date': DateFormat('MMM d, yyyy').format(DateTime.now()),
        'description': description,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('Log').doc(id).set(newData);
      print("Log saved");
    } catch (e) {
      print("Error saving log: $e");
    }
  }

  // Fetch all data
  // Future<List<Map<String, dynamic>>> fetchData() async {
  //   QuerySnapshot<Map<String, dynamic>> querySnapshot =
  //       await _firestore.collection('Log').get();

  //   return querySnapshot.docs.map((doc) => doc.data()).toList();
  // }
  Future<List<Map<String, dynamic>>> fetchData() async {
    QuerySnapshot<Map<String, dynamic>> querySnapshot =
        await _firestore.collection('Log').get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      final imageUrl = data['imageUrl'];

      // Check if 'imageUrl' exists and is not null
      if (imageUrl != null) {
        // If 'imageUrl' exists, include it in the data
        data['imageUrl'] = imageUrl;
      } else {
        // If 'imageUrl' is not present or is null, set it to null
        data['imageUrl'] = null;
      }

      return data;
    }).toList();
  }

  // Delete data
  Future<void> deleteData(String id) async {
    await _firestore.collection('Log').doc(id).delete();
  }

  // Upload image to Firebase Storage
  Future<String> _uploadImage(String id, File imageFile) async {
    final Reference storageRef = _storage.ref().child('images/$id.png');
    await storageRef.putFile(imageFile);
    return await storageRef.getDownloadURL();
  }

  // Helper function to generate unique ID (for simplicity)
  String _generateUniqueId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
  
}
