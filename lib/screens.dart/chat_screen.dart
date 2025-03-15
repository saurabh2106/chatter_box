import 'dart:io';

import 'package:chatter_box/screens.dart/chat_messages.dart';
import 'package:chatter_box/screens.dart/new_messages.dart';
import 'package:chatter_box/widgets/app_colors.dart';
import 'package:chatter_box/widgets/user_image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  String? profilePhoto;
  // File? selectedImage;
  final firebase = FirebaseAuth.instance;
  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _loadProfilePhoto();
  }

  // get user profile photo
  Future<void> _loadProfilePhoto() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Check if the user has a profile photo in FirebaseAuth
      if (user.photoURL != null) {
        setState(() {
          profilePhoto = user.photoURL;
        });
      } else {
        // If not available in FirebaseAuth, fetch from Firestore
        final userData = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userData.exists && userData.data()!.containsKey('profilePhoto')) {
          setState(() {
            profilePhoto = userData.data()!['profilePhoto'];
          });
        }
      }
    }
  }

  Future<void> changeProfilePhoto() async {
    File? newImage;
    await showModalBottomSheet<bool>(
      context: context,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Photo',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(
              height: 10,
            ),
            const Divider(
              color: Colors.black, // Line color
              thickness: 2, // Line thickness
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(50),
                color: MyAppColors.title,
              ),
              child: IconButton(
                color: MyAppColors.white,
                onPressed: () async {
                  final pickImage = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 90,
                    maxWidth: 150,
                  );
                  if (pickImage != null) {
                    setState(() {
                      newImage = File(pickImage.path);
                    });
                  } else {
                    return;
                  }

                  // ignore: use_build_context_synchronously
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.photo_library_outlined),
              ),
            )
          ],
        ),
      ),
    );
    if (newImage != null) {
      await uploadAndSaveProfilePhoto(newImage!);
    }
  }

  Future<void> uploadAndSaveProfilePhoto(File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final fileExt = path.extension(imageFile.path);
      final fileName = 'profile_${user.uid}$fileExt';
      final finalPath = 'chatterBox/$fileName';

      // delete earlier image
      await supabase.storage.from('chatterBox').remove([finalPath]);

      await supabase.storage.from('chatterBox').upload(finalPath, imageFile);

      // Get public URL
      final imageUrl =
          supabase.storage.from('chatterBox').getPublicUrl(finalPath);
      debugPrint("✅ Profile photo updated: $imageUrl");

      // Update Firebase Authentication
      await user.updatePhotoURL(imageUrl);

      // Update Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'profilePhoto': imageUrl,
      });

      // Update UI
      setState(() {
        profilePhoto = imageUrl;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile photo updated successfully!')),
      );
    } catch (error) {
      debugPrint("❌ Error updating profile photo: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update profile photo.')),
      );
    }
  }

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(ctx).pop(true);
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldSignOut == true) {
      await FirebaseAuth.instance.signOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: InkWell(
          onTap: () {
            changeProfilePhoto();
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: profilePhoto != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(profilePhoto!),
                  )
                : const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _confirmSignOut(context),
            icon: const Icon(Icons.exit_to_app),
          ),
        ],
        title: const Text('Chatter Box'),
      ),
      body: const Center(
        child: Column(
          children: [
            Expanded(child: ChatMessages()),
            NewMessages(),
          ],
        ),
      ),
    );
  }
}
