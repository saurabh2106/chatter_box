import 'package:chatter_box/screens.dart/chat_messages.dart';
import 'package:chatter_box/screens.dart/new_messages.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: FirebaseAuth.instance.signOut,
              icon: const Icon(Icons.exit_to_app))
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
