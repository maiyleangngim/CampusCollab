import 'package:flutter/material.dart';
import '../../models/study_group.dart';
import '../../widgets/message_bubble.dart';
import '../../widgets/chat_input_bar.dart';

class ChatDetailScreen extends StatelessWidget {
  final StudyGroup group;

  const ChatDetailScreen({super.key, required this.group});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              group.name,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${group.memberCount} Members • ${group.isOnline ? "Online" : "Offline"}',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: group.messages.length + 1, // +1 for the date separator
              itemBuilder: (context, index) {
                // Insert "TODAY" separator before the last section
                if (index == group.messages.length - 2) {
                  return Column(
                    children: [
                      MessageBubble(message: group.messages[index]),
                      _DateSeparator(label: 'TODAY'),
                    ],
                  );
                }
                if (index == group.messages.length) {
                  return const SizedBox.shrink();
                }
                return MessageBubble(message: group.messages[index]);
              },
            ),
          ),
          const Divider(height: 1),
          const ChatInputBar(),
        ],
      ),
    );
  }
}

class _DateSeparator extends StatelessWidget {
  final String label;
  const _DateSeparator({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Divider(color: Colors.grey[300])),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Divider(color: Colors.grey[300])),
        ],
      ),
    );
  }
}
