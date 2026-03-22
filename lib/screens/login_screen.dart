import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In
import 'home_screen.dart'; // Import HomeScreen
import 'register_screen.dart'; // Import RegisterScreen
import 'package:flutter_signin_button/flutter_signin_button.dart'; // Google Sign-In button
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Save user to AWS Lambda function
  Future<void> saveUserToDatabase(User user) async {
    Map<String, dynamic> userData = {
      'uid': user.uid,
      'email': user.email,
      'displayName': user.displayName ?? 'No Name',
      'photoURL': user.photoURL ?? '',
    };

    final String apiUrl = 'https://poiw4thrb5.execute-api.eu-north-1.amazonaws.com/prod/saveUser'; // API endpoint

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        print("User saved successfully in AWS!");
      } else {
        print("Failed to save user: ${response.body}");
      }
    } catch (e) {
      print("Error saving user: $e");
    }
  }

  // Check if the user exists in the database after login
  Future<void> checkIfUserExists(User user) async {
    final String apiUrl = 'https://poiw4thrb5.execute-api.eu-north-1.amazonaws.com/prod/checkUser'; // API endpoint for checking user

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'uid': user.uid}), // Send the UID to check if the user exists
      );

      if (response.statusCode == 200) {
        // If the user exists in the database
        print("User exists in database!");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      } else {
        // If the user doesn't exist in the database
        print("User does not exist in the database.");
        await saveUserToDatabase(user); // Save the new user to the database
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      print("Error checking user: $e");
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;  // User canceled the login

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential); // Login
      final User? user = userCredential.user;

      if (user != null) {
        // Check if the user already exists in the database
        await checkIfUserExists(user); // Check for user in DB
      }
    } catch (e) {
      print('Login failed: $e');
    }
  }

  // Sign in with email and password
  Future<void> signInWithEmail() async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final User? user = userCredential.user;

      if (user != null) {
        // Check if the user already exists in the database
        await checkIfUserExists(user); // Check for user in DB
      }
    } catch (e) {
      print('Login failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please try again.')),
      );
    }
  }

  // Check if user is already signed in silently
  Future<void> checkSignedInUser() async {
    final User? user = _auth.currentUser;
    if (user != null) {
      // If the user is already logged in, go to HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    }
  }

  // Go to Register Screen
  void goToRegisterScreen() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => RegisterScreen()),  // Navigate to RegisterScreen
    );
  }

  @override
  void initState() {
    super.initState();
    checkSignedInUser(); // Check if user is already signed in silently
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF4B3C2A), // Dark gold background
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset('assets/logo.png', height: 120),

                SizedBox(height: 40),

                // Render Google Sign In Button
                SignInButton(
                  Buttons.Google,
                  onPressed: signInWithGoogle,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  text: "Sign in with Google",  // Correct text for LoginScreen
                ),

                SizedBox(height: 20),

                // Email/Password Login
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    labelText: "Email",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),

                SizedBox(height: 10),

                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.6),
                    labelText: "Password",
                    labelStyle: TextStyle(color: Colors.white),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),

                SizedBox(height: 20),

                ElevatedButton(
                  onPressed: signInWithEmail,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Color(0xFF9C7F46), // Golden color
                  ),
                  child: Text('Sign in with Email', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),

                SizedBox(height: 20),

                // Register link
                GestureDetector(
                  onTap: goToRegisterScreen,
                  child: Text(
                    "Don't have an account? Register",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
