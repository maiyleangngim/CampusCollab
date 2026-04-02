import 'message.dart';

class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String courseCode;
  final String subject;
  final String template; // 'general' | 'exam_prep' | 'assignment'
  final int memberCount;
  final int maxMembers;
  final bool isOnline;
  final bool isPublic;
  final String lastMessage;
  final String lastMessageTime;
  final String inviteCode;
  final List<String> tags;
  final String createdBy;
  final Map<String, String> memberRoles; // uid -> 'owner'|'admin'|'member'|'mentor'
  final List<String> memberIds;
  final List<Message> messages;

  const StudyGroup({
    required this.id,
    required this.name,
    this.description = '',
    this.courseCode = '',
    this.subject = '',
    this.template = 'general',
    required this.memberCount,
    this.maxMembers = 20,
    required this.isOnline,
    this.isPublic = true,
    required this.lastMessage,
    required this.lastMessageTime,
    this.inviteCode = '',
    this.tags = const [],
    this.createdBy = '',
    this.memberRoles = const {},
    this.memberIds = const [],
    required this.messages,
  });

  factory StudyGroup.fromFirestore(Map<String, dynamic> data) => StudyGroup(
        id: data['id'] as String? ?? '',
        name: data['name'] as String? ?? '',
        description: data['description'] as String? ?? '',
        courseCode: data['courseCode'] as String? ?? '',
        subject: data['subject'] as String? ?? '',
        template: data['template'] as String? ?? 'general',
        memberCount: data['memberCount'] as int? ?? 0,
        maxMembers: data['maxMembers'] as int? ?? 20,
        isOnline: data['isOnline'] as bool? ?? false,
        isPublic: data['isPublic'] as bool? ?? true,
        lastMessage: data['lastMessage'] as String? ?? '',
        lastMessageTime: data['lastMessageTime']?.toString() ?? '',
        inviteCode: data['inviteCode'] as String? ?? '',
        tags: List<String>.from(data['tags'] as List? ?? []),
        createdBy: data['createdBy'] as String? ?? '',
        memberRoles: Map<String, String>.from(data['memberRoles'] as Map? ?? {}),
        memberIds: List<String>.from(data['memberIds'] as List? ?? []),
        messages: [],
      );
}
