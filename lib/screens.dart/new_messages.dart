import 'package:chatter_box/widgets/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class NewMessages extends StatefulWidget {
  const NewMessages({super.key});

  @override
  State<NewMessages> createState() => _NewMessagesState();
}

class _NewMessagesState extends State<NewMessages> {
  var messageController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void submitMessage() async {
    final enteredMessage = messageController.text;
    if (enteredMessage.trim().isEmpty) {
      return;
    }
    FocusScope.of(context).unfocus();
    // send message to firebase
    final currentUser = FirebaseAuth.instance.currentUser!;

    final userData = await FirebaseFirestore.instance
        .collection("users")
        .doc(currentUser.uid)
        .get();
    messageController.clear();

    await FirebaseFirestore.instance.collection('chat').add({
      'text': enteredMessage,
      'createAt': Timestamp.now(),
      'userId': currentUser.uid,
      'userName': userData.data()!['username'],
      'userImage': userData.data()!['profilePhoto'],
    });
  }

  void openEmojiKeyboard() {
    FocusScope.of(context).requestFocus(focusNode);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 5,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                focusNode: focusNode,
                controller: messageController,
                autocorrect: true,
                enableSuggestions: true,
                decoration: const InputDecoration(
                  hintText: "Type here...",
                  border: InputBorder.none,
                ),
              ),
            ),
            IconButton(
              icon:
                  const Icon(Icons.emoji_emotions_outlined, color: Colors.grey),
              onPressed: openEmojiKeyboard,
            ),
            IconButton(
              onPressed: submitMessage,
              icon: const Icon(Icons.send, color: MyAppColors.skyBlue),
            ),
          ],
        ),
      ),
    );
  }
}
