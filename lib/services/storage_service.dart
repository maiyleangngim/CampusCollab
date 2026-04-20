import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser!.uid;

  /// Upload a profile picture and return the download URL.
  Future<String> uploadProfilePicture(File file) async {
    final ref = _storage.ref().child('profile_pictures/$_uid.jpg');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  /// Upload a chat image and return the download URL.
  Future<String> uploadChatImage(String groupId, File file) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('chat_images/$groupId/$name');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  /// Upload a generic chat file and return the download URL.
  Future<String> uploadChatFile(String groupId, File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final dot = fileName.lastIndexOf('.');
    final ext = dot >= 0 ? fileName.substring(dot) : '';
    final safeExt = ext.isEmpty ? '' : ext;
    final name = '${DateTime.now().millisecondsSinceEpoch}$safeExt';
    final ref = _storage.ref().child('chat_files/$groupId/$name');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  /// Upload a direct-message image and return the download URL.
  Future<String> uploadDirectMessageImage(String conversationId, File file) async {
    final name = '${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = _storage.ref().child('direct_message_images/$conversationId/$name');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }

  /// Upload a direct-message file and return the download URL.
  Future<String> uploadDirectMessageFile(String conversationId, File file) async {
    final fileName = file.path.split(Platform.pathSeparator).last;
    final dot = fileName.lastIndexOf('.');
    final ext = dot >= 0 ? fileName.substring(dot) : '';
    final safeExt = ext.isEmpty ? '' : ext;
    final name = '${DateTime.now().millisecondsSinceEpoch}$safeExt';
    final ref = _storage.ref().child('direct_message_files/$conversationId/$name');
    await ref.putFile(file);
    return ref.getDownloadURL();
  }
}
