
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
import '../models/user_data.dart';
import '../models/user_profile.dart';

class FirebaseService {
 String user = FirebaseAuth.instance.currentUser!.uid;

 final databaseRef = FirebaseFirestore.instance.collection('licenses_data');

Future<void> addOrUpdateLicenseData() async {
  // Retrieve the current user's ID
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  // Check if a document with the same ID already exists
  final querySnapshot = await databaseRef.doc(currentUserId).get();
print(querySnapshot);
  if (querySnapshot.id.isNotEmpty) {
    // Document with the ID does not exist, create a new document
    await databaseRef.doc(user).set({
      "id": currentUserId,
      // Add other fields as necessary
    });
    print("Document created successfully.");
  } else {
    // Document already exists
    print("Document with ID already exists. Skipping creation.");
  }
}

// Fetch user data if exists
Future<UserLicenseData> getUserLicenseData() async {
  final docSnapshot = await databaseRef.doc(user).get();
  if (docSnapshot.exists) {
    final data = docSnapshot.data();

    if (data is Map<String, dynamic>) {
      // Map the data into UserLicenseData model
      return UserLicenseData.fromJson(data);
    } else {
      throw Exception('Unexpected data type: ${data.runtimeType}');
    }
  } else {
    throw Exception('User data not found');
  }
}

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<UserProfile?> getUserProfile() async {
    try {
      // Get the current user
      final user = FirebaseAuth.instance.currentUser;
Logger().i(user);
      if (user != null) {
        // Fetch user data from the 'users' collection
        DocumentSnapshot snapshot = await _db
            .collection('users')
            .doc(user.uid)
            .get();
print('User Profile fetched: ${snapshot.data()}');

        if (snapshot.exists) {
          return UserProfile.fromMap(snapshot.data() as Map<String, dynamic>);
        }
      }
    } catch (e) {
      print('Error fetching user profile: $e');
    }
    return null;
  }
}

