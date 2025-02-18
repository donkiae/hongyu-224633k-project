import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart'; 

class ProfilePage extends StatefulWidget {
  final String userId;

  const ProfilePage({super.key, required this.userId});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? profileImageBase64;
  String username = "Loading...";
  String email = "Loading...";
  bool isLoading = false;
  final TextEditingController usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserProfile();
  }

// use provider
  Future<void> fetchUserProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          profileImageBase64 = userDoc['profilePicture'];
          username = userDoc['username'] ?? "No Username";
          email = userDoc['email'] ?? "No Email";
          usernameController.text = username;
        });
      }
    } catch (e) {
      print("❌ Error fetching profile data: $e");
    }
  }

 //compress images in case too big
  Future<List<int>> compressImage(File imageFile) async {
    try {
      List<int>? compressedBytes = await FlutterImageCompress.compressWithFile(
        imageFile.absolute.path,
        minWidth: 200, 
        minHeight: 200,
        quality: 50, 
      );
      return compressedBytes ?? await imageFile.readAsBytes();
    } catch (e) {
      print("❌ Error compressing image: $e");
      return await imageFile.readAsBytes();
    }
  }

  // save to firestore 
  Future<void> saveProfilePicture(File imageFile) async {
    try {
      setState(() => isLoading = true);

      List<int> imageBytes = await compressImage(imageFile);
      String base64String = base64Encode(imageBytes);

      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        "profilePicture": base64String,
      });

      setState(() {
        profileImageBase64 = base64String;
      });

      Fluttertoast.showToast(
          msg: "Profile picture updated successfully!",
          gravity: ToastGravity.TOP);
    } catch (e) {
      print("❌ Error saving profile picture: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // for user to pick image
  Future<void> pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      File file = File(image.path);
      await saveProfilePicture(file);
    }
  }

  // update username
  Future<void> updateUsername() async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        "username": usernameController.text.trim(),
      });

      setState(() {
        username = usernameController.text.trim();
      });

      Fluttertoast.showToast(
          msg: "Username updated successfully!",
          gravity: ToastGravity.TOP);
    } catch (e) {
      print("❌ Error updating username: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF7EBCD), 
      child: Scaffold(
        backgroundColor: Colors.transparent, 
        appBar: AppBar(
          backgroundColor: const Color(0xFFDD6937), 
          title: const Text("Profile Page", style: TextStyle(color: Colors.white)),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        resizeToAvoidBottomInset: true, 
        body: SingleChildScrollView( 
          child: Padding(
            padding: const EdgeInsets.all(16.0), 
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLoading
                    ? const CircularProgressIndicator()
                    : CircleAvatar(
                        radius: 60,
                        backgroundImage: profileImageBase64 != null && profileImageBase64!.isNotEmpty
                            ? MemoryImage(base64Decode(profileImageBase64!))
                            : const AssetImage('images/default_avatar.png') as ImageProvider,
                        child: profileImageBase64 == null || profileImageBase64!.isEmpty
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                const SizedBox(height: 20),

                
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(color: Color(0xFFC24914)), 
                      border: const OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFC24914)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: const BorderSide(color: Color(0xFFC24914)),
                      ),
                    ),
                  ),
                ),

               
                ElevatedButton.icon(
                  onPressed: updateUsername,
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text("Update Username", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDD6937), 
                  ),
                ),

                const SizedBox(height: 10),

                Text(email, style: const TextStyle(fontSize: 16, color:  Color(0xFFDD6937))),
                const SizedBox(height: 20),

            
                ElevatedButton.icon(
                  onPressed: pickAndUploadImage,
                  icon: const Icon(Icons.camera_alt, color: Colors.white),
                  label: const Text("Change Profile Picture", style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDD6937),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}