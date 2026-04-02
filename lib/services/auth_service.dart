import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Stream of auth state changes — null means logged out.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Currently signed-in user, or null.
  User? get currentUser => _auth.currentUser;

  /// Sign in with email + password.
  Future<UserCredential> login(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Register new user and create their Firestore profile doc.
  Future<UserCredential> register(String name, String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await _db.collection('users').doc(cred.user!.uid).set({
      'displayName': name,
      'email': email,
      'major': '',
      'subjects': [],
      'avatarUrl': null,
      'isLookingForGroup': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return cred;
  }

  /// Sign out.
  Future<void> logout() => _auth.signOut();
}
