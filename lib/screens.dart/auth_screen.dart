// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:chatter_box/widgets/app_colors.dart';
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
  String _enterUserName = '';
  File? selectedImage;
  bool isPasswordVisible = false;

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

      if (selectedImage == null) {
        // debugPrint('❌ selectedImage is Null');
        return null;
      }

      await supabase.storage.from(bucketName).upload(finalPath, selectedImage!);

      final imageUrl =
          supabase.storage.from(bucketName).getPublicUrl(finalPath);
      debugPrint("✅ Image uploaded successfully: $imageUrl");

      return imageUrl;
    } catch (error, stackTrace) {
      debugPrint("❌ Upload failed: $error\nStackTrace: $stackTrace");
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
      await FirebaseAuth.instance.setLanguageCode('en');
      if (isLogin) {
        await firebase.signInWithEmailAndPassword(
            email: _enterEmail, password: _enterpassword);
        // debugPrint(userCredential);
      } else {
        final userCredential = await firebase.createUserWithEmailAndPassword(
            email: _enterEmail, password: _enterpassword);

        String? imageUrl;
        if (selectedImage != null) {
          debugPrint('selectedImage: $selectedImage');
          imageUrl = await uploadImageToSupabase(selectedImage!);
        }

        await FirebaseFirestore.instance
            .collection("users")
            .doc(userCredential.user!.uid)
            .set({
          'username': _enterUserName,
          "email": _enterEmail,
          "profilePhoto": imageUrl ?? '',
        });
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
      backgroundColor: MyAppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  height: 80,
                ),
                Opacity(
                  opacity: 0.8,
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 100,
                    height: 100,
                  ),
                ),
                const SizedBox(
                  height: 50,
                ),
                Form(
                  key: _formKey,
                  child: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            isLogin
                                ? 'Login to Chatter Box'
                                : 'Sign up to Chatter Box',
                            style: const TextStyle(
                                color: Colors.black,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
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
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              labelText: 'Email',
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Color(0xFF4A86F7),
                                    width: 2), // Primary Blue when focused
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Color(0xFF4A86F7),
                                    width: 1), // Primary Blue when not focused
                              ),
                            ),
                            autocorrect: false,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) {
                              if (value == null ||
                                  value.trim().isEmpty ||
                                  !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(value)) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                            onSaved: (newValue) {
                              _enterEmail = newValue!;
                            },
                          ),
                          if (!isLogin)
                            const SizedBox(
                              height: 20,
                            ),
                          if (!isLogin)
                            TextFormField(
                              // textCapitalization: TextCapitalization.words,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty ||
                                    value.trim().length < 4) {
                                  return 'Please enter valid username';
                                }
                                return null;
                              },
                              enableSuggestions: false,
                              onSaved: (newValue) {
                                _enterUserName = newValue!;
                              },
                              decoration: const InputDecoration(
                                labelText: 'username',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(10),
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: Color(0xFF4A86F7),
                                      width: 2), // Primary Blue when focused
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10)),
                                  borderSide: BorderSide(
                                      color: Color(0xFF4A86F7),
                                      width:
                                          1), // Primary Blue when not focused
                                ),
                              ),
                            ),
                          const SizedBox(
                            height: 20,
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
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                icon: Icon(
                                  !isPasswordVisible
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () {
                                  setState(() {
                                    isPasswordVisible = !isPasswordVisible;
                                  });
                                },
                              ),
                              border: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                  Radius.circular(10),
                                ),
                              ),
                              labelText: 'Password',
                              focusedBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Color(0xFF4A86F7), width: 2),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Color(0xFF4A86F7), width: 1),
                              ),
                            ),
                            obscureText: !isPasswordVisible,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: MyAppColors.primaryBlue,
                              foregroundColor: MyAppColors.white,
                              elevation: 6,
                              shadowColor: Colors.black54,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 14),
                            ),
                            onPressed: () async {
                              _onSubmit();
                            },
                            child: Text(
                              isLogin ? 'Login' : 'Sign Up',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white, // Ensuring contrast
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextButton(
                            style: TextButton.styleFrom(
                              // shadowColor: Colors.black12,
                              side: const BorderSide(
                                color: Colors.black12,
                                width: 1,
                              ),

                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(10), // Border radius
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 10),
                            ),
                            onPressed: () {
                              setState(() {
                                isLogin = !isLogin;
                              });
                            },
                            child: Text(
                              isLogin
                                  ? 'New User? Sign up'
                                  : 'Already have account',
                            ),
                          ),
                        ],
                      ),
                    ),
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
