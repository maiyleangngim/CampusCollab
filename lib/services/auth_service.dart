import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  /// Sign in with Google.
  Future<UserCredential> signInWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw Exception('cancelled');
    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await _auth.signInWithCredential(credential);
    await _ensureUserDoc(cred);
    return cred;
  }

  /// Sign in anonymously (debug / guest).
  Future<UserCredential> signInAnonymously() async {
    final cred = await _auth.signInAnonymously();
    await _ensureUserDoc(cred, displayName: 'Guest');
    return cred;
  }

  /// Creates a Firestore user doc if one doesn't exist yet.
  Future<void> _ensureUserDoc(UserCredential cred, {String? displayName}) async {
    final user = cred.user!;
    final doc = await _db.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      await _db.collection('users').doc(user.uid).set({
        'displayName': displayName ?? user.displayName ?? 'User',
        'email': user.email ?? '',
        'major': '',
        'subjects': [],
        'avatarUrl': user.photoURL,
        'isLookingForGroup': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Sign out.
  Future<void> logout() => _auth.signOut();
}
