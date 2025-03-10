import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  User? _user;
  bool isEditing = false;
  File? _imageFile;
  String? _imageUrl;

  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firebase
  Future<void> _fetchUserData() async {
    _user = _auth.currentUser;
    if (_user != null) {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(_user!.email).get();

      setState(() {
        nameController.text = userDoc['name'] ?? _user!.displayName ?? "";
        emailController.text = _user!.email ?? "";
        phoneController.text = userDoc['phone'] ?? "";
        _imageUrl = userDoc['photoUrl'] ?? _user!.photoURL;
      });
    }
  }

  // Pick Image from Camera or Gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_imageFile == null || _user == null) return;

    try {
      String filePath = 'profile_pictures/${_user!.uid}.jpg';
      Reference ref = FirebaseStorage.instance.ref().child(filePath);

      UploadTask uploadTask = ref.putFile(_imageFile!);
      TaskSnapshot snapshot = await uploadTask.whenComplete(() => null);  // Ensure completion

      String downloadUrl = await snapshot.ref.getDownloadURL();

      await _firestore.collection('users').doc(_user!.uid).update({
        'photoUrl': downloadUrl,
      });

      await _user!.updatePhotoURL(downloadUrl);

      setState(() {
        _imageUrl = downloadUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile picture updated successfully!")),
      );
    } catch (e) {
      print("🔥 Error uploading image: $e");
    }
  }

  // Update user info in Firebase Firestore & Authentication
  Future<void> _updateUserData() async {
    if (_user != null) {
      await _firestore.collection('users').doc(_user!.email).update({
        'name': nameController.text,
        'phone': phoneController.text,
      });

      await _user!.updateDisplayName(nameController.text);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully!")),
      );

      setState(() {
        isEditing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.lightBlueAccent,
        elevation: 0,
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Picture
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: _imageUrl != null
                            ? NetworkImage(_imageUrl!)
                            : const AssetImage("assets/images/profile.png")
                                as ImageProvider,
                      ),
                      if (isEditing)
                        IconButton(
                          icon: const Icon(Icons.camera_alt, color: Colors.blue),
                          onPressed: () => _showImagePickerOptions(),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Profile Fields
                  _buildProfileField("Full Name", nameController),
                  _buildProfileField("Email", emailController, isEditable: false),
                  _buildProfileField("Phone Number", phoneController),

                  const SizedBox(height: 20),

                  // Save Button
                  if (isEditing)
                    ElevatedButton(
                      onPressed: _updateUserData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12, horizontal: 24),
                      ),
                      child: const Text("Save Changes",
                          style: TextStyle(fontSize: 16)),
                    ),
                ],
              ),
            ),

      // Edit Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            isEditing = !isEditing;
          });
        },
        backgroundColor: Colors.blueAccent,
        child: Icon(isEditing ? Icons.close : Icons.edit, color: Colors.white),
      ),
    );
  }

  // Show Image Picker Options (Camera / Gallery)
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera),
              title: const Text("Take a Photo"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text("Choose from Gallery"),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        );
      },
    );
  }

  // Reusable Profile Field
  Widget _buildProfileField(String label, TextEditingController controller,
      {bool isEditable = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: isEditing && isEditable,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            filled: true,
            fillColor: isEditing ? Colors.white : Colors.grey.shade100,
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
