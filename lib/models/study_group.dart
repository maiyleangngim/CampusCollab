import 'message.dart';

class StudyGroup {
  final String id;
  final String name;
  final int memberCount;
  final bool isOnline;
  final String lastMessage;
  final String lastMessageTime;
  final List<Message> messages;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.memberCount,
    required this.isOnline,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.messages,
  });
}
