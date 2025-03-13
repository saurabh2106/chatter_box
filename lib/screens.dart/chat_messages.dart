import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:chatter_box/widgets/chat_bubble.dart';

class ChatMessages extends StatefulWidget {
  const ChatMessages({super.key});

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
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

        _scrollToBottom();

        return ListView.builder(
          controller: _scrollController,
          itemCount: loadedMessages.length,
          itemBuilder: (context, index) {
            final chatMessage = loadedMessages[index].data();
            final previousMessage =
                index > 0 ? loadedMessages[index - 1].data() : null;

            final currentMsgUserId = chatMessage['userId'];
            final previousMsgUserId =
                previousMessage != null ? previousMessage['userId'] : null;

            final showProfileImage = previousMsgUserId != currentMsgUserId;
            final Timestamp timestamp = chatMessage['createAt'];
            final DateTime dateTime = timestamp.toDate();
            final String formattedTime = DateFormat('HH:mm').format(dateTime);

            return ChatBubble(
              username: chatMessage['userName'],
              message: chatMessage['text'],
              isMe: authenticatedUser.uid == currentMsgUserId,
              time: formattedTime,
              profileImage: chatMessage['userImage'] ?? '',
              showProfileImage: showProfileImage,
            );
          },
        );
      },
    );
  }
}
