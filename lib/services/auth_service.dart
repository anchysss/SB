import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

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
        await _saveUserToFirestore(user, name: name.trim());
        if (context.mounted) Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      if (context.mounted) _showError(context, e.message ?? 'Sign-up failed.');
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
      if (!context.mounted) return;
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        _showError(context, 'Invalid email or password. Please try again.');
      } else {
        _showError(context, e.message ?? 'Sign-in failed.');
      }
    }
  }

  // ── Google sign-in ────────────────────────────────────────────
  Future<void> signInWithGoogle(BuildContext context) async {
    if (kIsWeb) return; // web uses GIS — handled separately
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
        await _saveUserToFirestore(user);
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
        await _saveUserToFirestore(user, name: name.isNotEmpty ? name : null);
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

  // ── Helpers ───────────────────────────────────────────────────
  Future<void> _saveUserToFirestore(User user, {String? name}) async {
    final doc = await _db.collection('Users').doc(user.uid).get();
    if (!doc.exists) {
      await _db.collection('Users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': name ?? user.displayName ?? 'Reader',
        'created_at': FieldValue.serverTimestamp(),
        'steamy_clicks': 0,
        'progress': {},
        'purchases': [],
        'preferred_genres': [],
      });
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
