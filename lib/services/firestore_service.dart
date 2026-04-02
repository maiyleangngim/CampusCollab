import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';
import '../models/study_group.dart';
import '../models/discover_group.dart';
import '../models/task.dart';
import '../models/study_session.dart';
import '../models/resource_item.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Not authenticated');
    return uid;
  }

  // ── HELPERS ─────────────────────────────────────────────────────────────────

  /// Generate a random 8-character alphanumeric invite code.
  static String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random.secure();
    return List.generate(8, (_) => chars[rand.nextInt(chars.length)]).join();
  }

  // ── USER ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile(Map<String, dynamic> fields) {
    return _db.collection('users').doc(_uid).update(fields);
  }

  Future<int> getKarmaTotal() async {
    final doc = await _db.collection('users').doc(_uid).get();
    return (doc.data()?['karma'] as int?) ?? 0;
  }

  Future<void> addKarma(int points) async {
    await _db.collection('users').doc(_uid).update({
      'karma': FieldValue.increment(points),
    });
  }

  // ── GROUPS ──────────────────────────────────────────────────────────────────

  /// Real-time stream of groups the current user is a member of.
  Stream<List<StudyGroup>> myGroupsStream() {
    return _db
        .collection('studyGroups')
        .where('memberIds', arrayContains: _uid)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StudyGroup.fromFirestore({'id': d.id, ...d.data()}))
            .toList());
  }

  /// One-time fetch of all discover groups (public groups not yet joined).
  Future<List<StudyGroup>> getDiscoverGroups() async {
    final snap = await _db
        .collection('studyGroups')
        .where('isPublic', isEqualTo: true)
        .limit(50)
        .get();
    return snap.docs
        .map((d) => StudyGroup.fromFirestore({'id': d.id, ...d.data()}))
        .toList();
  }

  /// One-time fetch of all discover groups (legacy DiscoverGroup model).
  Future<List<DiscoverGroup>> getDiscoverGroupsLegacy() async {
    final snap = await _db.collection('discoverGroups').get();
    return snap.docs
        .map((d) => DiscoverGroup.fromJson({'id': d.id, ...d.data()}))
        .toList();
  }

  /// Create a new study group and set the creator as owner.
  Future<String> createGroup({
    required String name,
    required String description,
    required String courseCode,
    required String subject,
    required String template,
    required int maxMembers,
    required bool isPublic,
    required List<String> tags,
  }) async {
    final user = _auth.currentUser!;
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final inviteCode = _generateInviteCode();

    final ref = await _db.collection('studyGroups').add({
      'name': name,
      'description': description,
      'courseCode': courseCode,
      'subject': subject,
      'template': template,
      'maxMembers': maxMembers,
      'isPublic': isPublic,
      'tags': tags,
      'memberIds': [user.uid],
      'memberRoles': {user.uid: 'owner'},
      'memberCount': 1,
      'inviteCode': inviteCode,
      'isOnline': false,
      'lastMessage': 'Group created',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdBy': user.uid,
      'createdByName': userDoc.data()?['displayName'] ?? 'Unknown',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Award karma for creating a group
    await addKarma(20);

    return ref.id;
  }

  /// Join a group by its ID.
  Future<void> joinGroup(String groupId) async {
    await _db.collection('studyGroups').doc(groupId).update({
      'memberIds': FieldValue.arrayUnion([_uid]),
      'memberRoles.$_uid': 'member',
      'memberCount': FieldValue.increment(1),
    });
    await addKarma(5);
  }

  /// Join a group by its invite code. Returns groupId on success, throws if not found.
  Future<String> joinGroupByCode(String code) async {
    final snap = await _db
        .collection('studyGroups')
        .where('inviteCode', isEqualTo: code.toUpperCase().trim())
        .limit(1)
        .get();
    if (snap.docs.isEmpty) throw Exception('Invalid invite code.');
    final groupId = snap.docs.first.id;
    final data = snap.docs.first.data();
    final memberIds = List<String>.from(data['memberIds'] ?? []);
    if (memberIds.contains(_uid)) throw Exception('You are already a member.');
    await joinGroup(groupId);
    return groupId;
  }

  /// Leave a group.
  Future<void> leaveGroup(String groupId) async {
    await _db.collection('studyGroups').doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([_uid]),
      'memberCount': FieldValue.increment(-1),
    });
    // Remove role entry
    await _db.collection('studyGroups').doc(groupId).update({
      'memberRoles.$_uid': FieldValue.delete(),
    });
  }

  /// Get full user data for all members of a group.
  Future<List<Map<String, dynamic>>> getGroupMembers(String groupId) async {
    final groupDoc = await _db.collection('studyGroups').doc(groupId).get();
    final data = groupDoc.data();
    if (data == null) return [];
    final memberIds = List<String>.from(data['memberIds'] ?? []);
    final roles = Map<String, String>.from(data['memberRoles'] ?? {});
    final results = <Map<String, dynamic>>[];
    for (final uid in memberIds) {
      final userDoc = await _db.collection('users').doc(uid).get();
      if (userDoc.exists) {
        results.add({
          'uid': uid,
          'role': roles[uid] ?? 'member',
          ...userDoc.data()!,
        });
      }
    }
    return results;
  }

  /// Regenerate the invite code for a group (owner/admin only).
  Future<String> regenerateInviteCode(String groupId) async {
    final newCode = _generateInviteCode();
    await _db.collection('studyGroups').doc(groupId).update({'inviteCode': newCode});
    return newCode;
  }

  /// Get the current user's role in a group.
  Future<String> getUserRole(String groupId) async {
    final doc = await _db.collection('studyGroups').doc(groupId).get();
    final roles = Map<String, String>.from(doc.data()?['memberRoles'] ?? {});
    return roles[_uid] ?? 'member';
  }

  // ── MESSAGES ────────────────────────────────────────────────────────────────

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
    await addKarma(1);
  }

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

  // ── TASKS ────────────────────────────────────────────────────────────────────

  Stream<List<Task>> tasksStream(String groupId) {
    return _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('tasks')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => Task.fromFirestore(d.id, d.data())).toList());
  }

  Future<void> addTask(String groupId, String title) async {
    await _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('tasks')
        .add({
      'title': title,
      'isCompleted': false,
      'createdBy': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> toggleTask(String groupId, String taskId, bool completed) async {
    await _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .update({'isCompleted': completed});
    if (completed) await addKarma(3);
  }

  Future<void> deleteTask(String groupId, String taskId) {
    return _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .delete();
  }

  // ── STUDY SESSIONS ───────────────────────────────────────────────────────────

  /// Stream of all study sessions across all of the user's groups.
  Stream<List<StudySession>> mySessionsStream() {
    return _db
        .collection('studyGroups')
        .where('memberIds', arrayContains: _uid)
        .snapshots()
        .asyncMap((groupSnap) async {
      final sessions = <StudySession>[];
      for (final groupDoc in groupSnap.docs) {
        final sessionSnap = await _db
            .collection('studyGroups')
            .doc(groupDoc.id)
            .collection('sessions')
            .get();
        for (final s in sessionSnap.docs) {
          sessions.add(StudySession.fromFirestore(s.id, {
            'groupId': groupDoc.id,
            ...s.data(),
          }));
        }
      }
      sessions.sort((a, b) => a.startTime.compareTo(b.startTime));
      return sessions;
    });
  }

  Stream<List<StudySession>> groupSessionsStream(String groupId) {
    return _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('sessions')
        .orderBy('startTime')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => StudySession.fromFirestore(d.id, {
                  'groupId': groupId,
                  ...d.data(),
                }))
            .toList());
  }

  Future<void> addSession(String groupId, StudySession session) async {
    await _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('sessions')
        .add(session.toMap());
    await addKarma(5);
  }

  Future<void> deleteSession(String groupId, String sessionId) {
    return _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('sessions')
        .doc(sessionId)
        .delete();
  }

  // ── RESOURCES ────────────────────────────────────────────────────────────────

  Stream<List<ResourceItem>> resourcesStream(String groupId) {
    return _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('resources')
        .orderBy('uploadedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ResourceItem.fromFirestore(d.id, d.data()))
            .toList());
  }

  Future<void> addLinkResource(
      String groupId, String title, String url) async {
    final user = _auth.currentUser!;
    final userDoc = await _db.collection('users').doc(user.uid).get();
    final name = userDoc.data()?['displayName'] ?? 'Unknown';
    await _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('resources')
        .add({
      'type': 'link',
      'title': title,
      'url': url,
      'uploadedBy': user.uid,
      'uploadedByName': name,
      'uploadedAt': FieldValue.serverTimestamp(),
    });
    await addKarma(5);
  }

  Future<void> deleteResource(String groupId, String resourceId) {
    return _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('resources')
        .doc(resourceId)
        .delete();
  }
}
