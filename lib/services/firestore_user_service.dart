import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Save user data to Firestore
  Future<void> saveUserData({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
  }) async {
    // Get current user
    User? user = _auth.currentUser;

    if (user != null) {
      // Create user data map
      Map<String, dynamic> userData = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Save to Firestore with user's UID as document ID
      await _firestore.collection('users').doc(user.uid).set(userData);
    } else {
      throw Exception('No authenticated user found');
    }
  }

  // Get user data from Firestore
  Future<Map<String, dynamic>?> getUserData() async {
    User? user = _auth.currentUser;

    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      } else {
        return null;
      }
    } else {
      return null;
    }
  }
}