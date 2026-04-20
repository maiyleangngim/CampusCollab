import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/message.dart';
import '../models/study_group.dart';
import '../models/discover_group.dart';
import '../models/direct_message_conversation.dart';
import '../models/user_privacy.dart';
import '../models/task.dart';
import '../models/study_session.dart';
import '../models/resource_item.dart';
import '../models/chat_folder.dart';

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

  static String _directConversationId(String uidA, String uidB) {
    final ids = [uidA, uidB]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  DocumentReference<Map<String, dynamic>> _privacyDoc(String uid) {
    return _db.collection('userPrivacy').doc(uid);
  }

  DocumentReference<Map<String, dynamic>> _dmDoc(String conversationId) {
    return _db.collection('directMessages').doc(conversationId);
  }

  Future<void> _assertCanDm(String targetUid) async {
    if (targetUid == _uid) {
      throw Exception('You cannot message yourself.');
    }

    final myPrivacy = await getMyPrivacy();
    final targetPrivacy = await getUserPrivacy(targetUid);

    if (myPrivacy.blockedUsers.contains(targetUid) ||
        targetPrivacy.blockedUsers.contains(_uid)) {
      throw Exception('Direct messaging is unavailable due to block settings.');
    }

    if (targetPrivacy.dmAccess == 'none') {
      throw Exception('This user is not accepting direct messages right now.');
    }
  }

  // ── USER ────────────────────────────────────────────────────────────────────

  Future<Map<String, dynamic>?> getUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data();
  }

  Future<void> updateUserProfile(Map<String, dynamic> fields) {
    return _db.collection('users').doc(_uid).update(fields);
  }

  Future<UserPrivacy> getMyPrivacy() async {
    final doc = await _privacyDoc(_uid).get();
    return UserPrivacy.fromFirestore(_uid, doc.data());
  }

  Future<UserPrivacy> getUserPrivacy(String uid) async {
    final doc = await _privacyDoc(uid).get();
    return UserPrivacy.fromFirestore(uid, doc.data());
  }

  Future<void> updateMyPrivacy({
    String? dmAccess,
    String? profileVisibility,
  }) async {
    final data = <String, dynamic>{};
    if (dmAccess != null) data['dmAccess'] = dmAccess;
    if (profileVisibility != null) data['profileVisibility'] = profileVisibility;
    if (data.isEmpty) return;
    await _privacyDoc(_uid).set(data, SetOptions(merge: true));
  }

  Future<void> blockUser(String targetUid) async {
    if (targetUid == _uid) return;
    await _privacyDoc(_uid).set({
      'blockedUsers': FieldValue.arrayUnion([targetUid]),
    }, SetOptions(merge: true));
  }

  Future<void> unblockUser(String targetUid) async {
    await _privacyDoc(_uid).set({
      'blockedUsers': FieldValue.arrayRemove([targetUid]),
    }, SetOptions(merge: true));
  }

  Future<bool> isBlockedEitherDirection(String targetUid) async {
    final mine = await getMyPrivacy();
    final theirs = await getUserPrivacy(targetUid);
    return mine.blockedUsers.contains(targetUid) ||
        theirs.blockedUsers.contains(_uid);
  }

  Future<void> reportUser({
    required String targetUid,
    required String reason,
    String? note,
  }) async {
    await _db.collection('userReports').add({
      'reporterUid': _uid,
      'targetUid': targetUid,
      'reason': reason,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<List<Map<String, dynamic>>> searchUsersByDisplayName(
    String query, {
    int limit = 20,
  }) async {
    final q = query.trim();
    if (q.isEmpty) return [];

    final myPrivacy = await getMyPrivacy();
    final blockedByMe = myPrivacy.blockedUsers.toSet();

    final snap = await _db
        .collection('users')
        .orderBy('displayName')
        .startAt([q])
        .endAt(['$q\uf8ff'])
        .limit(limit)
        .get();

    return snap.docs
        .where((doc) => doc.id != _uid && !blockedByMe.contains(doc.id))
        .map((doc) => {
              'uid': doc.id,
              ...doc.data(),
            })
        .toList();
  }

  Future<bool> sharesAnyGroupWith(String targetUid) async {
    final mine = await _db
        .collection('studyGroups')
        .where('memberIds', arrayContains: _uid)
        .limit(120)
        .get();
    for (final doc in mine.docs) {
      final members = List<String>.from(doc.data()['memberIds'] ?? const []);
      if (members.contains(targetUid)) return true;
    }
    return false;
  }

  Future<Map<String, dynamic>?> getVisibleUserProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;

    final blocked = await isBlockedEitherDirection(uid);
    if (blocked) {
      return {
        'uid': uid,
        'displayName': doc.data()?['displayName'] ?? 'Unknown',
        'blocked': true,
      };
    }

    final privacy = await getUserPrivacy(uid);
    final profile = <String, dynamic>{
      'uid': uid,
      ...?doc.data(),
      'blocked': false,
      'profileVisibility': privacy.profileVisibility,
    };

    if (privacy.profileVisibility == 'private') {
      return {
        'uid': uid,
        'displayName': profile['displayName'] ?? 'Unknown',
        'avatarUrl': profile['avatarUrl'],
        'blocked': false,
        'limitedProfile': true,
      };
    }

    if (privacy.profileVisibility == 'shared_group') {
      final shared = await sharesAnyGroupWith(uid);
      if (!shared) {
        return {
          'uid': uid,
          'displayName': profile['displayName'] ?? 'Unknown',
          'avatarUrl': profile['avatarUrl'],
          'blocked': false,
          'limitedProfile': true,
        };
      }
    }

    profile['limitedProfile'] = false;
    return profile;
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

  /// Fetch a single group document.
  Future<StudyGroup?> getGroup(String groupId) async {
    final doc = await _db.collection('studyGroups').doc(groupId).get();
    if (!doc.exists) return null;
    final data = doc.data()!..['id'] = doc.id;
    return StudyGroup.fromFirestore(data);
  }

  /// Remove a member from a group (owner/admin only — enforced in UI).
  Future<void> kickMember(String groupId, String targetUid) async {
    await _db.collection('studyGroups').doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([targetUid]),
      'memberCount': FieldValue.increment(-1),
      'memberRoles.$targetUid': FieldValue.delete(),
    });
  }

  /// Set a member's role ('admin' or 'member') — owner only in UI.
  Future<void> setMemberRole(
      String groupId, String targetUid, String role) async {
    await _db
        .collection('studyGroups')
        .doc(groupId)
        .update({'memberRoles.$targetUid': role});
  }

  /// Update group name/description/courseCode. Pass only the fields to change.
  Future<void> updateGroupInfo(
    String groupId, {
    String? name,
    String? description,
    String? courseCode,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (courseCode != null) data['courseCode'] = courseCode;
    if (data.isEmpty) return;
    await _db.collection('studyGroups').doc(groupId).update(data);
  }

  /// Permanently delete a group document (owner only — enforced in UI).
  Future<void> deleteGroup(String groupId) async {
    await _db.collection('studyGroups').doc(groupId).delete();
  }

  // ── DIRECT MESSAGES ────────────────────────────────────────────────────────

  Future<String> getOrCreateDirectConversation(String targetUid) async {
    await _assertCanDm(targetUid);

    final me = _uid;
    final conversationId = _directConversationId(me, targetUid);
    final conversationRef = _dmDoc(conversationId);
    final existing = await conversationRef.get();
    if (existing.exists) return conversationId;

    final myUser = await _db.collection('users').doc(me).get();
    final targetUser = await _db.collection('users').doc(targetUid).get();
    final myName = myUser.data()?['displayName'] ?? 'Unknown';
    final targetName = targetUser.data()?['displayName'] ?? 'Unknown';
    final myAvatar = myUser.data()?['avatarUrl'];
    final targetAvatar = targetUser.data()?['avatarUrl'];

    final batch = _db.batch();
    batch.set(conversationRef, {
      'participantIds': [me, targetUid],
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    batch.set(
      _db.collection('users').doc(me).collection('directConversations').doc(conversationId),
      {
        'participantIds': [me, targetUid],
        'otherUserId': targetUid,
        'otherUserName': targetName,
        if (targetAvatar != null) 'otherUserAvatarUrl': targetAvatar,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      _db.collection('users').doc(targetUid).collection('directConversations').doc(conversationId),
      {
        'participantIds': [me, targetUid],
        'otherUserId': me,
        'otherUserName': myName,
        if (myAvatar != null) 'otherUserAvatarUrl': myAvatar,
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
    return conversationId;
  }

  Stream<List<DirectMessageConversation>> myDirectConversationsStream() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('directConversations')
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => DirectMessageConversation.fromFirestore(d.id, d.data()))
            .toList());
  }

  Stream<List<Message>> directMessagesStream(String conversationId) {
    return _dmDoc(conversationId)
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
                fileUrl: data['fileUrl'],
                fileName: data['fileName'],
                fileSubtitle: data['fileSubtitle'],
                timestamp: ts is Timestamp ? ts.toDate() : DateTime.now(),
                isMe: data['senderId'] == _uid,
                isEdited: data['isEdited'] as bool? ?? false,
                reactions: _parseReactions(data['reactions']),
              );
            }).toList());
  }

  Future<void> sendDirectTextMessage(String conversationId, String text) async {
    final me = _uid;
    final convo = await _dmDoc(conversationId).get();
    if (!convo.exists) throw Exception('Conversation not found.');
    final participantIds = List<String>.from(convo.data()?['participantIds'] ?? const []);
    if (!participantIds.contains(me)) {
      throw Exception('You do not have access to this conversation.');
    }
    final otherUid = participantIds.firstWhere((id) => id != me, orElse: () => '');
    await _assertCanDm(otherUid);

    final userDoc = await _db.collection('users').doc(me).get();
    final name = userDoc.data()?['displayName'] ?? 'Unknown';
    final avatarUrl = userDoc.data()?['avatarUrl'];
    final otherDoc = await _db.collection('users').doc(otherUid).get();
    final otherName = otherDoc.data()?['displayName'] ?? 'Unknown';
    final otherAvatar = otherDoc.data()?['avatarUrl'];

    final batch = _db.batch();
    final msgRef = _dmDoc(conversationId).collection('messages').doc();
    batch.set(msgRef, {
      'senderId': me,
      'senderName': name,
      if (avatarUrl != null) 'senderAvatarUrl': avatarUrl,
      'type': 'text',
      'content': text,
      'timestamp': FieldValue.serverTimestamp(),
    });
    batch.update(_dmDoc(conversationId), {
      'lastMessage': text,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });

    batch.set(
      _db.collection('users').doc(me).collection('directConversations').doc(conversationId),
      {
        'participantIds': participantIds,
        'otherUserId': otherUid,
        'otherUserName': otherName,
        if (otherAvatar != null) 'otherUserAvatarUrl': otherAvatar,
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    batch.set(
      _db.collection('users').doc(otherUid).collection('directConversations').doc(conversationId),
      {
        'participantIds': participantIds,
        'otherUserId': me,
        'otherUserName': name,
        if (avatarUrl != null) 'otherUserAvatarUrl': avatarUrl,
        'lastMessage': text,
        'lastMessageTime': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );

    await batch.commit();
  }

  Future<void> toggleDirectReaction(
      String conversationId, String messageId, String emoji) async {
    final uid = _uid;
    final ref = _dmDoc(conversationId).collection('messages').doc(messageId);
    final doc = await ref.get();
    final rawReactions =
        Map<String, dynamic>.from(doc.data()?['reactions'] as Map? ?? {});
    final uids = List<String>.from(rawReactions[emoji] as List? ?? []);
    if (uids.contains(uid)) {
      uids.remove(uid);
    } else {
      uids.add(uid);
    }
    if (uids.isEmpty) {
      rawReactions.remove(emoji);
    } else {
      rawReactions[emoji] = uids;
    }
    await ref.update({'reactions': rawReactions});
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
                fileUrl: data['fileUrl'],
                fileName: data['fileName'],
                fileSubtitle: data['fileSubtitle'],
                timestamp: ts is Timestamp ? ts.toDate() : DateTime.now(),
                isMe: data['senderId'] == _uid,
                isEdited: data['isEdited'] as bool? ?? false,
                reactions: _parseReactions(data['reactions']),
              );
            }).toList());
  }

  Map<String, List<String>> _parseReactions(dynamic raw) {
    if (raw == null) return {};
    final map = raw as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, List<String>.from(v as List)));
  }

  Future<void> deleteMessage(String groupId, String messageId) {
    return _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  Future<void> editMessage(
      String groupId, String messageId, String newText) async {
    await _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId)
        .update({'content': newText, 'isEdited': true});

    // Update the group preview if this was the latest message
    final latest = await _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();
    if (latest.docs.isNotEmpty && latest.docs.first.id == messageId) {
      await _db
          .collection('studyGroups')
          .doc(groupId)
          .update({'lastMessage': newText});
    }
  }

  Future<void> toggleReaction(
      String groupId, String messageId, String emoji) async {
    final uid = _uid;
    final ref = _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('messages')
        .doc(messageId);
    final doc = await ref.get();
    final rawReactions =
        Map<String, dynamic>.from(doc.data()?['reactions'] as Map? ?? {});
    final uids = List<String>.from(rawReactions[emoji] as List? ?? []);
    if (uids.contains(uid)) {
      uids.remove(uid);
    } else {
      uids.add(uid);
    }
    if (uids.isEmpty) {
      rawReactions.remove(emoji);
    } else {
      rawReactions[emoji] = uids;
    }
    await ref.update({'reactions': rawReactions});
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

  Future<void> sendFileMessage(
    String groupId, {
    required String fileUrl,
    required String fileName,
    String? fileSubtitle,
  }) async {
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
      'type': 'file',
      'fileUrl': fileUrl,
      'fileName': fileName,
      if (fileSubtitle != null && fileSubtitle.isNotEmpty)
        'fileSubtitle': fileSubtitle,
      'timestamp': FieldValue.serverTimestamp(),
    });
    batch.update(_db.collection('studyGroups').doc(groupId), {
      'lastMessage': '📎 $fileName',
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

  Future<void> addTask(
    String groupId, {
    required String title,
    String? description,
    String? priority,
    DateTime? dueDate,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'isCompleted': false,
      'createdBy': _uid,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (description != null && description.isNotEmpty) data['description'] = description;
    if (priority != null) data['priority'] = priority;
    if (dueDate != null) data['dueDate'] = Timestamp.fromDate(dueDate);
    await _db.collection('studyGroups').doc(groupId).collection('tasks').add(data);
  }

  Future<void> updateTask(
    String groupId,
    String taskId, {
    String? title,
    String? description,
    bool clearDescription = false,
    String? priority,
    bool clearPriority = false,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) async {
    final data = <String, dynamic>{};
    if (title != null) data['title'] = title;
    if (clearDescription) {
      data['description'] = FieldValue.delete();
    } else if (description != null) {
      data['description'] = description;
    }
    if (clearPriority) {
      data['priority'] = FieldValue.delete();
    } else if (priority != null) {
      data['priority'] = priority;
    }
    if (clearDueDate) {
      data['dueDate'] = FieldValue.delete();
    } else if (dueDate != null) {
      data['dueDate'] = Timestamp.fromDate(dueDate);
    }
    if (data.isEmpty) return;
    await _db
        .collection('studyGroups')
        .doc(groupId)
        .collection('tasks')
        .doc(taskId)
        .update(data);
  }

  /// Stream of all tasks across every group the current user belongs to.
  /// Each task has [groupId] and [groupName] injected for cross-group display.
  Stream<List<Task>> myTasksStream() {
    return _db
        .collection('studyGroups')
        .where('memberIds', arrayContains: _uid)
        .snapshots()
        .asyncMap((groupSnap) async {
      final tasks = <Task>[];
      for (final groupDoc in groupSnap.docs) {
        final groupName = groupDoc.data()['name'] as String? ?? '';
        final taskSnap = await _db
            .collection('studyGroups')
            .doc(groupDoc.id)
            .collection('tasks')
            .get();
        for (final taskDoc in taskSnap.docs) {
          final data = Map<String, dynamic>.from(taskDoc.data());
          data['groupId'] = groupDoc.id;
          data['groupName'] = groupName;
          tasks.add(Task.fromFirestore(taskDoc.id, data));
        }
      }
      // Tasks with deadlines first (sorted by deadline), then no-deadline tasks
      tasks.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
      return tasks;
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

  // ── CHAT FOLDERS ─────────────────────────────────────────────────────────────

  Stream<List<ChatFolder>> foldersStream() {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('chatFolders')
        .orderBy('createdAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => ChatFolder.fromFirestore(d.id, d.data()))
            .toList());
  }

  Future<void> createFolder(String name) async {
    await _db
        .collection('users')
        .doc(_uid)
        .collection('chatFolders')
        .add({
      'name': name,
      'groupIds': [],
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteFolder(String folderId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('chatFolders')
        .doc(folderId)
        .delete();
  }

  Future<void> addGroupToFolder(String folderId, String groupId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('chatFolders')
        .doc(folderId)
        .update({'groupIds': FieldValue.arrayUnion([groupId])});
  }

  Future<void> removeGroupFromFolder(String folderId, String groupId) {
    return _db
        .collection('users')
        .doc(_uid)
        .collection('chatFolders')
        .doc(folderId)
        .update({'groupIds': FieldValue.arrayRemove([groupId])});
  }
}
