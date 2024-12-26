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
        return Scaffold(  
          appBar: AppBar(  
            title: const Text('Profile'),  
            centerTitle: true,  
             // Change to your desired color  
          ),  
          body: _buildBody(snapshot),  
        );  
      },  
    );  
  }  

  Widget _buildBody(AsyncSnapshot<UserProfile?> snapshot) {  
    if (snapshot.connectionState == ConnectionState.waiting) {  
      return _buildLoadingIndicator();  
    } else if (snapshot.connectionState == ConnectionState.done) {  
      if (snapshot.hasData) {  
        final userProfile = snapshot.data;  
        return _buildProfileContent(userProfile!);  
      } else {  
        return _buildNoProfileDataFound();  
      }  
    } else if (snapshot.hasError) {  
      return _buildErrorState(snapshot.error.toString());  
    } else {  
      return const Center(child: Text('Unknown state.'));  
    }  
  }  

  Widget _buildLoadingIndicator() {  
    return Center(  
      child: CircularProgressIndicator(),  
    );  
  }  

  Widget _buildNoProfileDataFound() {  
    return const Center(  
      child: Text(  
        'No profile data found.',  
        style: TextStyle(fontSize: 18, color: Colors.red),  
      ),  
    );  
  }  

  Widget _buildErrorState(String error) {  
    return Center(  
      child: Text(  
        'Error fetching profile data: $error',  
        style: TextStyle(color: Colors.red),  
      ),  
    );  
  }  

  Widget _buildProfileContent(UserProfile userProfile) {  
    return Padding(  
      padding: const EdgeInsets.all(16.0),  
      child: ListView(  
        children: [  
          // Profile Picture  
          Center(  
            child: CircleAvatar(  
              radius: 50,  
              backgroundImage: userProfile.profilePictureUrl != null  
                  ? NetworkImage(userProfile.profilePictureUrl!)  
                  : const AssetImage('assets/default_avatar.png') as ImageProvider,  
            ),  
          ),  
          const SizedBox(height: 16),  
          // User Name  
          Text(  
            userProfile.name ?? 'No Name',  
            textAlign: TextAlign.center,  
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),  
          ),  
          const SizedBox(height: 8),  
          // User Email and Phone Number  
          _buildInfoItem(Icons.email, userProfile.email ?? 'No Email'),  
          _buildInfoItem(Icons.phone, userProfile.phoneNumber ?? 'No Phone'),  
          const SizedBox(height: 20),  
          // Edit Profile Button  
          ElevatedButton(  
            onPressed: () {  
              // TODO: Implement edit profile functionality  
            },  
            child: const Text('Edit Profile'),  
            style: ElevatedButton.styleFrom(  
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),  
              shape: RoundedRectangleBorder(  
                borderRadius: BorderRadius.circular(30.0),  
              ),  
            ),  
          ),  
        ],  
      ),  
    );  
  }  

  Widget _buildInfoItem(IconData icon, String info) {  
    return Card(  
      elevation: 4,  
      shape: RoundedRectangleBorder(  
        borderRadius: BorderRadius.circular(10),  
      ),  
      margin: const EdgeInsets.symmetric(vertical: 8),  
      child: Padding(  
        padding: const EdgeInsets.all(16.0),  
        child: Row(  
          children: [  
            Icon(icon,),  
            const SizedBox(width: 10),  
            Expanded(  
              child: Text(  
                info,  
                style: const TextStyle(fontSize: 18),  
              ),  
            ),  
          ],  
        ),  
      ),  
    );  
  }  
}