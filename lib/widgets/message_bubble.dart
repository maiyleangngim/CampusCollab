import 'package:flutter/material.dart';
import '../models/message.dart';

class MessageBubble extends StatelessWidget {
  final Message message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isMe) {
      return _SentBubble(message: message);
    } else {
      return _ReceivedBubble(message: message);
    }
  }
}

// ── Sent (right-aligned, blue) ──────────────────────────────────────────────

class _SentBubble extends StatelessWidget {
  final Message message;
  const _SentBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 60, right: 12, top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Flexible(child: _buildContent(context)),
          const SizedBox(width: 8),
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.blue[300],
            child: const Icon(Icons.person, size: 16, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 200,
            height: 150,
            color: Colors.blue[100],
            child: const Icon(Icons.image, size: 48, color: Colors.blueGrey),
          ),
        );
      case MessageType.file:
        return _FileCard(message: message, isMe: true);
      case MessageType.text:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.blue[700],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(4),
            ),
          ),
          child: Text(
            message.text ?? '',
            style: const TextStyle(color: Colors.white, fontSize: 14.5),
          ),
        );
    }
  }
}

// ── Received (left-aligned, white) ──────────────────────────────────────────

class _ReceivedBubble extends StatelessWidget {
  final Message message;
  const _ReceivedBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, right: 60, top: 4, bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Colors.grey[400],
            child: Text(
              message.senderName[0],
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.senderName,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 3),
                _buildContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (message.type) {
      case MessageType.image:
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: 200,
            height: 150,
            color: Colors.grey[300],
            child: const Icon(Icons.image, size: 48, color: Colors.blueGrey),
          ),
        );
      case MessageType.file:
        return _FileCard(message: message, isMe: false);
      case MessageType.text:
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1)),
            ],
          ),
          child: Text(
            message.text ?? '',
            style: const TextStyle(color: Colors.black87, fontSize: 14.5),
          ),
        );
    }
  }
}

// ── File card (shared doc) ───────────────────────────────────────────────────

class _FileCard extends StatelessWidget {
  final Message message;
  final bool isMe;
  const _FileCard({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? Colors.blue[600] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: isMe ? null : Border.all(color: Colors.grey[200]!),
        boxShadow: isMe
            ? null
            : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 1))],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isMe ? Colors.blue[800] : Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.description, color: isMe ? Colors.white : Colors.blue[700], size: 24),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.fileName ?? 'File',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isMe ? Colors.white : Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  message.fileSubtitle ?? '',
                  style: TextStyle(fontSize: 11, color: isMe ? Colors.blue[100] : Colors.grey[500]),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Icon(Icons.open_in_new, size: 16, color: isMe ? Colors.white70 : Colors.grey[500]),
        ],
      ),
    );
  }
}
