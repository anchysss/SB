@JS()
library google_identity_login;

import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:js/js.dart';

@JS('google.accounts.id.initialize')
external void initialize(IdentityConfiguration config);

@JS('google.accounts.id.prompt')
external void prompt(void Function(PromptMomentNotification));

@JS('google.accounts.id.renderButton')
external void renderButton(dynamic parent, ButtonConfiguration config);

@JS()
@anonymous
class IdentityConfiguration {
  external String get client_id;
  external Function(CredentialResponse) get callback;

  external factory IdentityConfiguration({
    required String client_id,
    required Function(CredentialResponse) callback,
  });
}

@JS()
@anonymous
class CredentialResponse {
  external String get credential;
}

@JS()
@anonymous
class PromptMomentNotification {}

@JS()
@anonymous
class ButtonConfiguration {
  external String get theme;
  external String get size;
  external String get type;
  external int get width;

  external factory ButtonConfiguration({
    required String theme,
    required String size,
    required String type,
    required int width,
  });
}

class GoogleWebLoginService {
  static void showGoogleSignInButton({
    required BuildContext context,
    required String clientId,
    required GlobalKey containerKey,
  }) {
    initialize(
      IdentityConfiguration(
        client_id: clientId,
        callback: allowInterop((CredentialResponse response) async {
          try {
            final credential = GoogleAuthProvider.credential(
              idToken: response.credential,
            );

            final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
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

              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            }
          } catch (e) {
            print('❌ GIS login error: $e');
          }
        }),
      ),
    );

    renderButton(
      containerKey.currentContext!.findRenderObject(),
      ButtonConfiguration(
        theme: 'filled_black',
        size: 'large',
        type: 'standard',
        width: 300,
      ),
    );

    prompt(allowInterop((_) {}));
  }
}
