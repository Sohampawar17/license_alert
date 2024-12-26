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
