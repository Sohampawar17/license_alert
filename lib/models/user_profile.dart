import 'package:firebase_auth/firebase_auth.dart';  
import 'package:logger/logger.dart';  

class UserProfile {  
  String? name;  
  String? email;  
  String? profilePictureUrl;  
  String? phoneNumber;  

  UserProfile({  
    this.name,  
    this.email,  
    this.profilePictureUrl,  
    this.phoneNumber,  
  });  

  // Factory method to create UserProfile from a Map  
  factory UserProfile.fromMap(Map<String, dynamic> map) {  
    return UserProfile(  
      name: map['name'],  
      email: map['email'],  
      profilePictureUrl: map['profilePictureUrl'],  
      phoneNumber: map['phoneNumber'],  
    );  
  }  
}  

Future<UserProfile?> getUserProfile() async {  
  try {  
    // Get the current user  
    final user = FirebaseAuth.instance.currentUser;  
    Logger().i(user);  

    if (user != null) {  
      // Create a UserProfile instance using the user properties  
      return UserProfile(  
        name: user.displayName, // Extract display name  
        email: user.email, // Extract email  
        profilePictureUrl: user.photoURL, // Extract photo URL  
        phoneNumber: user.phoneNumber, // Extract phone number  
      );  
    }  
  } catch (e) {  
    Logger().e('Error fetching user profile: $e');  
  }  
  return null;  
}