import 'package:chatter_box/widgets/chat_bubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  void setupPushNotification() async {
    final fcm = FirebaseMessaging.instance;
    await fcm.requestPermission();
    final token = await fcm.getToken();
    fcm.subscribeToTopic('chat');
    print('token $token');
  }

  @override
  void initState() {
    setupPushNotification();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authenticatedUser = FirebaseAuth.instance.currentUser!;

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('chat')
          .orderBy('createAt')
          .snapshots(),
      builder: (context, chatSnapshot) {
        if (chatSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (!chatSnapshot.hasData || chatSnapshot.data!.docs.isEmpty) {
          return const Center(child: Text('No messages found'));
        }
        if (chatSnapshot.hasError) {
          return const Center(child: Text('Error...something went wrong'));
        }

        final loadedMessages = chatSnapshot.data!.docs;

        return ListView.builder(
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final nextMessage = index + 1 < loadedMessages.length
                ? loadedMessages[index + 1].data()
                : null;

            final currentMsgUserId = chatMessage['userId'];
            final nextMsgUserId =
                nextMessage != null ? nextMessage['userId'] : null;
            final showProfileImage = currentMsgUserId != nextMsgUserId;

            return ChatBubble(
              username: chatMessage['userName'],
              message: chatMessage['text'],
              isMe: authenticatedUser.uid == currentMsgUserId,
              time: '09:00', // Replace with formatted timestamp
              profileImage: chatMessage['userImage'] ?? '',
              showProfileImage: showProfileImage,
            );
          },
        );
      },
    );
  }
}
