import 'package:firebase_auth/firebase_auth.dart';

class UserHelper {
  static String getCurrentUserId() {
    return FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
  }
}
