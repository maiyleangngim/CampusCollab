enum MessageType { text, image, file }

class Message {
  final String id;
  final String senderId;
  final String senderName;
  final MessageType type;
  final String? text;
  final String? imageUrl;
  final String? fileName;
  final String? fileSubtitle;
  final DateTime timestamp;
  final bool isMe;

  const Message({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.type,
    required this.timestamp,
    required this.isMe,
    this.text,
    this.imageUrl,
    this.fileName,
    this.fileSubtitle,
  });
}
