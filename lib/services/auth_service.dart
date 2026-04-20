import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'otp_service.dart';
import 'email_service.dart';

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
    final normalizedEmail = email.trim().toLowerCase();
    UserCredential cred;

    try {
      cred = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // If the account already exists, allow the user to continue only when
      // that existing account is still unverified.
      if (e.code != 'email-already-in-use') rethrow;

      final existingCred = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final userDoc = await _db.collection('users').doc(existingCred.user!.uid).get();
      final isVerifiedInFirestore = userDoc.data()?['emailVerified'] == true;
      if (isVerifiedInFirestore) {
        throw FirebaseAuthException(code: 'email-already-in-use');
      }

      final existingName =
          (userDoc.data()?['displayName'] as String?)?.trim() ?? '';
      final nameForEmail = existingName.isNotEmpty ? existingName : name;
      final code = await OtpService()
          .generateAndStore(existingCred.user!.uid, OtpPurpose.emailVerification);
      await EmailService()
          .sendVerificationCode(toEmail: normalizedEmail, name: nameForEmail, code: code);
      return existingCred;
    }

    try {
      await _db.collection('users').doc(cred.user!.uid).set({
        'displayName': name,
        'email': normalizedEmail,
        'major': '',
        'subjects': [],
        'avatarUrl': null,
        'isLookingForGroup': false,
        'emailVerified': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Generate a 6-digit OTP and send it via email instead of Firebase's link
      final code = await OtpService()
          .generateAndStore(cred.user!.uid, OtpPurpose.emailVerification);
      await EmailService()
          .sendVerificationCode(toEmail: normalizedEmail, name: name, code: code);
      return cred;
    } catch (_) {
      // Roll back partially-created auth/profile state if OTP delivery fails.
      await _db.collection('users').doc(cred.user!.uid).delete().catchError((_) {});
      await cred.user?.delete().catchError((_) {});
      await _auth.signOut().catchError((_) {});
      rethrow;
    }
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
        'emailVerified': true, // Google/anonymous users are pre-verified
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  /// Sign out.
  Future<void> logout() => _auth.signOut();
}