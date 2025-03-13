import 'package:chatter_box/screens.dart/auth_screen.dart';
import 'package:chatter_box/screens.dart/chat_screen.dart';
import 'package:chatter_box/screens.dart/splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

void main() async {
  // Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://qzmccewjkuddqglvbfai.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InF6bWNjZXdqa3VkZHFnbHZiZmFpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzg0MTA2MDYsImV4cCI6MjA1Mzk4NjYwNn0.FkE0c-mf3c0zFIVmpM4bJjgW4qTBI7ts30t2xSMH7Hw',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> isUserDeleted(user) async {
    if (user == null) return false;
    try {
      await user.reload();
      return FirebaseAuth.instance.currentUser == null;
    } catch (e) {
      return true; // Error likely means the user no longer exists
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chatter Box',
      theme: ThemeData().copyWith(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 63, 17, 177),
        ),
        useMaterial3: true,
      ),
      home: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SplashScreen();
          }
          if (snapshot.hasData) {
            final user = FirebaseAuth.instance.currentUser;
            return FutureBuilder<bool>(
              future: isUserDeleted(user),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SplashScreen(); // Show loading state
                }
                if (userSnapshot.data == true) {
                  FirebaseAuth.instance.signOut();
                  return const AuthScreen(); // Redirect to login
                }
                return const ChatScreen();
              },
            );
          } else {
            return const AuthScreen();
          }
        },
      ),
    );
  }
}
