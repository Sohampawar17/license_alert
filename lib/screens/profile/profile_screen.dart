import 'package:flutter/material.dart';

import '../../models/user_profile.dart';
import '../../services/userdata_services.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
  future: FirebaseService().getUserProfile(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else if (snapshot.connectionState == ConnectionState.done) {
      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }
      if (snapshot.hasData) {
        final userProfile = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            title: Text('Profile'),
          ),
          body: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: userProfile!.profilePictureUrl != null
                      ? NetworkImage(userProfile.profilePictureUrl!)
                      : AssetImage('assets/default_avatar.png') as ImageProvider,
                ),
                SizedBox(height: 16),
                Text(
                  userProfile.name ?? 'No Name',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  userProfile.email ?? 'No Email',
                  style: TextStyle(fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  userProfile.phoneNumber ?? 'No Phone',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
          ),
        );
      } else {
        return Center(child: Text('No profile data found.'));
      }
    } else {
      return Center(child: Text('Loading...'));
    }
  },
)
;
  }
}
