import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleWebLoginService {
  static void showGoogleSignInButton({
    required BuildContext context,
    required String clientId,
    required GlobalKey containerKey,
  }) {
    final script = html.ScriptElement()
      ..src = "https://accounts.google.com/gsi/client"
      ..async = true
      ..defer = true;

    html.document.head!.append(script);

    script.onLoad.listen((_) {
      js.context.callMethod('eval', ["""
        window.handleCredentialResponse = function(response) {
          const idToken = response.credential;
          window.flutter_inappwebview.callHandler('onGoogleLogin', idToken);
        };

        if (window.google && window.google.accounts) {
          window.google.accounts.id.initialize({
            client_id: "$clientId",
            callback: handleCredentialResponse
          });

          window.google.accounts.id.renderButton(
            document.getElementById("google-button-container"),
            { theme: "filled_black", size: "large" }
          );
        }
      """]);
    });
  }

  static Future<void> signInWithIdToken(String idToken, BuildContext context) async {
    final credential = GoogleAuthProvider.credential(idToken: idToken);
    final userCredential =
        await FirebaseAuth.instance.signInWithCredential(credential);

    final user = userCredential.user;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await FirebaseFirestore.instance
            .collection('Users')
            .doc(user.uid)
            .set({
          'uid': user.uid,
          'email': user.email,
          'name': user.displayName ?? '',
          'created_at': FieldValue.serverTimestamp(),
          'steamy_clicks': 0,
          'progress': {},
          'purchases': [],
          'preferred_genres': [],
        });
      }

      Navigator.pushReplacementNamed(context, '/home');
    }
  }
}
