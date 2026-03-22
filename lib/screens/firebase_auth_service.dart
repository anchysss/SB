import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  // Google login
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled the sign-in process
        return null;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      return userCredential.user;
    } catch (e) {
      print("Google SignIn Error: $e");
      return null;
    }
  }

  // Email login
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Email SignIn Error: $e");
      return null;
    }
  }

  // Register with Email
  Future<User?> registerWithEmail(String email, String password) async {
    try {
      // Provera da li korisnik već postoji
      final User? existingUser = await getUserByEmail(email);
      if (existingUser != null) {
        print("User with this email already exists.");
        return null;
      }

      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      return userCredential.user;
    } catch (e) {
      print("Registration Error: $e");
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  // Get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Helper function to check if user exists by email
  Future<User?> getUserByEmail(String email) async {
    try {
      final List<String> methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isEmpty) {
        return null; // No user found with this email
      }
      return _auth.currentUser; // User exists
    } catch (e) {
      print("Error fetching user by email: $e");
      return null;
    }
  }
}
