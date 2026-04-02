import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  // ── USER ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile(Map<String, dynamic> fields) {
    return _db.collection('users').doc(_uid).update(fields);
  }

  // ── GROUPS ──────────────────────────────────────────────────────────────────

  /// Real-time stream of groups the current user is a member of.
  Stream<List<Map<String, dynamic>>> myGroupsStream() {
    return _db
        .collection('studyGroups')
        .where('memberIds', arrayContains: _uid)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => {'id': d.id, ...d.data()})
            .toList());
  }

  /// One-time fetch of all discover groups.
  Future<List<Map<String, dynamic>>> getDiscoverGroups() async {
    final snap = await _db.collection('discoverGroups').get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  // ── MESSAGES ────────────────────────────────────────────────────────────────

  /// Real-time stream of messages for a group, ordered oldest-first.
  Stream<List<Message>> messagesStream(String groupId) {
    return _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snap) => snap.docs.map((d) {
              final data = d.data();
              final ts = data['timestamp'];
              return Message(
                id: d.id,
                senderId: data['senderId'] ?? '',
                senderName: data['senderName'] ?? '',
                type: _parseType(data['type']),
                text: data['content'],
                imageUrl: data['imageUrl'],
                fileName: data['fileName'],
                timestamp: ts is Timestamp ? ts.toDate() : DateTime.now(),
                isMe: data['senderId'] == _uid,
              );
            }).toList());
  }

  /// Send a plain text message.
  Future<void> sendTextMessage(String groupId, String text) async {
    final user = _auth.currentUser!;
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final name = userDoc.data()?['displayName'] ?? 'Unknown';

    final batch = _db.batch();
    final msgRef = _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('messages')
        .doc();

    batch.set(msgRef, {
      'senderId': user.uid,
      'senderName': name,
      'type': 'text',
      'content': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    batch.update(_db.collection('studyGroups').doc(groupId), {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  /// Send an image message (imageUrl already uploaded to Storage).
  Future<void> sendImageMessage(String groupId, String imageUrl) async {
    final user = _auth.currentUser!;
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final name = userDoc.data()?['displayName'] ?? 'Unknown';

    final batch = _db.batch();
    final msgRef = _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('messages')
        .doc();

    batch.set(msgRef, {
      'senderId': user.uid,
      'senderName': name,
      'type': 'image',
      'imageUrl': imageUrl,
      'timestamp': FieldValue.serverTimestamp(),
    });

    batch.update(_db.collection('studyGroups').doc(groupId), {
      'lastMessage': '📷 Image',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  MessageType _parseType(dynamic raw) {
    if (raw == 'image') return MessageType.image;
    if (raw == 'file') return MessageType.file;
    return MessageType.text;
  }
}
