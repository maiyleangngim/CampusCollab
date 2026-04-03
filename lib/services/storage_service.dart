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
}
