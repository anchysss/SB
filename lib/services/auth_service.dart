import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'aws_users_service.dart';

class AuthService {
  final FirebaseAuth      _auth        = FirebaseAuth.instance;
  final FirebaseFirestore _db          = FirebaseFirestore.instance;
  final GoogleSignIn      _googleSignIn = GoogleSignIn();
  final AWSUsersService   _aws         = AWSUsersService();

  // ── Email sign-up ─────────────────────────────────────────────
  Future<void> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required BuildContext context,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      final user = cred.user;
      if (user != null) {
        await user.updateDisplayName(name.trim());
        await _saveUser(user, name: name.trim());
        if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) _showError(context, _authError(e));
    }
  }

  // ── Email sign-in ─────────────────────────────────────────────
  Future<void> signInWithEmail({
    required String email,
    required String password,
    required BuildContext context,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );
      if (cred.user != null && context.mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) _showError(context, _authError(e));
    }
  }

  // ── Google sign-in ────────────────────────────────────────────
  Future<void> signInWithGoogle(BuildContext context) async {
    if (kIsWeb) return;
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      final user = userCred.user;
      if (user != null) {
        await _saveUser(user);
        if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (context.mounted) _showError(context, 'Google Sign-In failed. Please try again.');
    }
  }

  // ── Apple sign-in ─────────────────────────────────────────────
  Future<void> signInWithApple(BuildContext context) async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      final userCred = await _auth.signInWithCredential(oauthCredential);
      final user = userCred.user;
      if (user != null) {
        final name = [appleCredential.givenName, appleCredential.familyName]
            .where((p) => p != null && p.isNotEmpty)
            .join(' ');
        await _saveUser(user, name: name.isNotEmpty ? name : null);
        if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code == AuthorizationErrorCode.canceled) return;
      if (context.mounted) _showError(context, 'Apple Sign-In failed: ${e.message}');
    } catch (e) {
      if (context.mounted) _showError(context, 'Apple Sign-In failed. Please try again.');
    }
  }

  // ── Password reset ────────────────────────────────────────────
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reset link sent! Check your inbox.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) _showError(context, e.message ?? 'Could not send reset email.');
    }
  }

  // ── Sign out ──────────────────────────────────────────────────
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // ─────────────────────────────────────────────────────────────
  //  Core: save new user to BOTH Firestore and AWS DynamoDB
  //
  //  • Firestore  → real-time profile (progress, coins, comments)
  //  • DynamoDB   → user catalogue, analytics, cross-service data
  //
  //  Only saves if the user doesn't exist yet (first sign-in).
  //  AWS failure is non-critical — user is still registered.
  // ─────────────────────────────────────────────────────────────
  Future<void> _saveUser(User user, {String? name}) async {
    final resolvedName = name ?? user.displayName ?? 'Reader';
    final email        = user.email ?? '';
    final photoUrl     = user.photoURL ?? '';

    // 1️⃣  Firestore — skip if already exists
    final doc = await _db.collection('Users').doc(user.uid).get();
    if (!doc.exists) {
      await _db.collection('Users').doc(user.uid).set({
        'uid':               user.uid,
        'email':             email,
        'name':              resolvedName,
        'photo_url':         photoUrl,
        'created_at':        FieldValue.serverTimestamp(),
        'steamy_clicks':     0,
        'progress':          {},   // { book_id: last_chapter_number }
        'purchases':         [],   // [ chapter_id, ... ]
        'preferred_genres':  [],
        'coins':             0,
      });
      print('✅ Firestore: user saved (${user.uid})');

      // 2️⃣  AWS DynamoDB — fire-and-forget, non-critical
      _aws.saveUserData(user.uid, email, resolvedName, photoUrl).catchError((e) {
        print('⚠️  AWS DynamoDB save failed (non-critical): $e');
      });
    }
  }

  // ─────────────────────────────────────────────────────────────
  //  Helpers
  // ─────────────────────────────────────────────────────────────
  String _authError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      default:
        return e.message ?? 'Something went wrong.';
    }
  }

  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
