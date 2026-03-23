import '../models/message.dart';
import '../models/study_group.dart';

final List<StudyGroup> dummyGroups = [
  StudyGroup(
    id: 'g1',
    name: 'Study Group: Advanced Physics',
    memberCount: 12,
    isOnline: true,
    lastMessage: 'Person 2: Physics Study Guide.docx',
    lastMessageTime: '10:42 AM',
    messages: _physicsMessages,
  ),
  StudyGroup(
    id: 'g2',
    name: 'Calculus II — Exam Prep',
    memberCount: 8,
    isOnline: true,
    lastMessage: 'Person 3: Does anyone have the practice set?',
    lastMessageTime: '9:15 AM',
    messages: _calculusMessages,
  ),
  StudyGroup(
    id: 'g3',
    name: 'CS301 — Algorithms Help',
    memberCount: 5,
    isOnline: false,
    lastMessage: "You: I'll share my notes tonight",
    lastMessageTime: 'Yesterday',
    messages: _algorithmMessages,
  ),
  StudyGroup(
    id: 'g4',
    name: 'ITM 390 — Mobile Dev',
    memberCount: 3,
    isOnline: true,
    lastMessage: 'Person 5: Flutter setup done!',
    lastMessageTime: 'Yesterday',
    messages: _mobileMessages,
  ),
  StudyGroup(
    id: 'g5',
    name: 'General Study — Library B2',
    memberCount: 20,
    isOnline: false,
    lastMessage: 'Person 6: See everyone at 3 PM',
    lastMessageTime: 'Mon',
    messages: _generalMessages,
  ),
];

final List<Message> _physicsMessages = [
  Message(
    id: 'm1',
    senderId: 'u1',
    senderName: 'Person 1',
    type: MessageType.text,
    text: 'Has anyone started the problem set due Thursday? I\'m stuck on the quantum mechanics part.',
    timestamp: DateTime(2026, 3, 23, 9, 30),
    isMe: false,
  ),
  Message(
    id: 'm2',
    senderId: 'me',
    senderName: 'Me',
    type: MessageType.text,
    text: 'I just finished the first two questions. Here are my notes for the second one. Hope it helps!',
    timestamp: DateTime(2026, 3, 23, 9, 45),
    isMe: true,
  ),
  Message(
    id: 'm3',
    senderId: 'me',
    senderName: 'Me',
    type: MessageType.image,
    imageUrl: 'assets/images/notes_placeholder.png',
    timestamp: DateTime(2026, 3, 23, 9, 46),
    isMe: true,
  ),
  Message(
    id: 'm4',
    senderId: 'u2',
    senderName: 'Person 2',
    type: MessageType.text,
    text: 'Thanks! I\'m putting everything into our shared study guide doc here so we can all collaborate:',
    timestamp: DateTime(2026, 3, 23, 10, 42),
    isMe: false,
  ),
  Message(
    id: 'm5',
    senderId: 'u2',
    senderName: 'Person 2',
    type: MessageType.file,
    fileName: 'Physics Study Guide.docx',
    fileSubtitle: 'Shared via Google Drive',
    timestamp: DateTime(2026, 3, 23, 10, 42),
    isMe: false,
  ),
];

final List<Message> _calculusMessages = [
  Message(
    id: 'c1',
    senderId: 'u3',
    senderName: 'Person 3',
    type: MessageType.text,
    text: 'Does anyone have the practice set from last week?',
    timestamp: DateTime(2026, 3, 23, 9, 10),
    isMe: false,
  ),
  Message(
    id: 'c2',
    senderId: 'me',
    senderName: 'Me',
    type: MessageType.text,
    text: 'I think I saved it — let me check my Drive.',
    timestamp: DateTime(2026, 3, 23, 9, 15),
    isMe: true,
  ),
];

final List<Message> _algorithmMessages = [
  Message(
    id: 'a1',
    senderId: 'u4',
    senderName: 'Person 4',
    type: MessageType.text,
    text: 'Who\'s going to the TA session tomorrow?',
    timestamp: DateTime(2026, 3, 22, 18, 0),
    isMe: false,
  ),
  Message(
    id: 'a2',
    senderId: 'me',
    senderName: 'Me',
    type: MessageType.text,
    text: 'I\'ll share my notes tonight.',
    timestamp: DateTime(2026, 3, 22, 18, 30),
    isMe: true,
  ),
];

final List<Message> _mobileMessages = [
  Message(
    id: 'mob1',
    senderId: 'u5',
    senderName: 'Person 5',
    type: MessageType.text,
    text: 'Flutter setup done! Ready to start on the UI.',
    timestamp: DateTime(2026, 3, 22, 14, 0),
    isMe: false,
  ),
];

final List<Message> _generalMessages = [
  Message(
    id: 'gen1',
    senderId: 'u6',
    senderName: 'Person 6',
    type: MessageType.text,
    text: 'See everyone at 3 PM at the library B2!',
    timestamp: DateTime(2026, 3, 21, 11, 0),
    isMe: false,
  ),
];
