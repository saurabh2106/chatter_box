import 'dart:io';
import 'package:chatter_box/widgets/user_image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart' as path;

final firebase = FirebaseAuth.instance;
final supabase = Supabase.instance.client;

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  var isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String _enterEmail = '';
  String _enterpassword = '';
  File? selectedImage;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Function to upload image to Supabase Storage

  Future<String?> uploadImageToSupabase(File file) async {
    try {
      const bucketName = 'chatterBox';
      final fileExt = path.extension(file.path);
      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}$fileExt';
      final finalPath = 'chatterBox/$fileName';

      // final userId = supabase.auth.currentUser!.id;

      // Convert File to Uint8List
      // final fileBytes = await file.readAsBytes();

      // Upload as binary data
      if (selectedImage == null) {
        print('selectedImage is Null');
        return null;
      }
      await Supabase.instance.client.storage
          .from(bucketName)
          .upload(
            finalPath,
            selectedImage!,
            // fileBytes,
            // fileOptions: const FileOptions(upsert: true),
          )
          .then(
            (value) => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Image uploaded successfully'))),
          );

      final imageUrl = Supabase.instance.client.storage
          .from(bucketName)
          .getPublicUrl(fileName);

      print("✅ Image uploaded successfully: $imageUrl");
      return imageUrl;
    } catch (error) {
      print("❌ Upload failed: $error");
      return null;
    }
  }

  Future<void> _onSubmit() async {
    final bool isValid = _formKey.currentState!.validate();
    if (!isValid || (!isLogin && selectedImage == null)) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please add a image')));
      return;
    }
    _formKey.currentState!.save();

    try {
      if (isLogin) {
        final userCredential = await firebase.signInWithEmailAndPassword(
            email: _enterEmail, password: _enterpassword);
        print(userCredential);
      } else {
        final userCredential = await firebase.createUserWithEmailAndPassword(
            email: _enterEmail, password: _enterpassword);

        String? imageUrl;
        if (selectedImage != null) {
          print('selectedImage: $selectedImage');
          imageUrl = await uploadImageToSupabase(selectedImage!);
        }

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
          "email": _enterEmail,
          "profilePhoto": imageUrl,
        });

        print("User signed up with profile photo: $imageUrl");
      }
    } on FirebaseException catch (error) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message ?? 'Authentication Failed')));
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Form(
            key: _formKey,
            child: Card(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Welcome back'),
                      const SizedBox(height: 10),
                      if (!isLogin)
                        UserImagePicker(
                          onPickedImage: (pickedImage) {
                            setState(() {
                              selectedImage = pickedImage;
                            });
                          },
                        ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Email address'),
                        autocorrect: false,
                        textCapitalization: TextCapitalization.none,
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty ||
                              !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enterEmail = newValue!;
                        },
                      ),
                      TextFormField(
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.trim().length < 6) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                        onSaved: (newValue) {
                          _enterpassword = newValue!;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Password',
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer),
                          onPressed: _onSubmit,
                          child: Text(isLogin ? 'Login' : 'Sign Up')),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            isLogin = !isLogin;
                          });
                        },
                        child: Text(isLogin
                            ? 'New User? Sign up'
                            : 'Already have account'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
