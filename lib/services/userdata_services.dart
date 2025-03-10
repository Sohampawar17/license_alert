
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
  if (querySnapshot.data() == null) {
    // Document with the ID does not exist, create a new document
    await databaseRef.doc(user).set({
      "id": currentUserId,
      
      // Add other fields as necessary
    });
  } else {
    // Document already exists
  }
}

// Fetch user data if exists
Future<UserLicenseData> getUserLicenseData() async {  
  final docSnapshot = await databaseRef.doc(user).get();  
  if (docSnapshot.exists) {  
    final data = docSnapshot.data();  
    Logger().i(data); // Ensure this output matches expected structure  

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

Future<UserProfile?> getUserProfile() async {  
  try {  
    // Get the current user  
    final user = FirebaseAuth.instance.currentUser;  
    Logger().i(user);  

    if (user != null) {  
      // Create a map from user properties  
      final userMap = {  
        'name': user.displayName, // Extract display name  
        'email': user.email, // Extract email  
        'profilePictureUrl': user.photoURL, // Extract photo URL  
        'phone': user.phoneNumber, // Extract phone number  
      };  

      // Create and return UserProfile from the map  
      return UserProfile.fromMap(userMap);  
    }  
  } catch (e) {  
    Logger().e('Error fetching user profile: $e');  
  }  
  return null;  
}
}

