import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart'; // Google Sign-In
import 'home_screen.dart'; // Import HomeScreen
import 'login_screen.dart'; // Import LoginScreen
import 'package:flutter_signin_button/flutter_signin_button.dart'; // Google Sign-In button
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
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

  // Sign up with Google using google_sign_in package
  Future<void> signUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;  // User canceled the login

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Use signInWithCredential for Google registration (sign up)
      final UserCredential userCredential = await _auth.signInWithCredential(credential); // Correct method for registration
      final User? user = userCredential.user;

      if (user != null) {
        // Save new user to the database if not already present
        await saveUserToDatabase(user);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      print('Signup with Google failed: $e');
    }
  }

  // Register with email and password
  Future<void> registerWithEmail() async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );
      final User? user = userCredential.user;
      
      if (user != null) {
        // Save new user to the database
        await saveUserToDatabase(user);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()),
        );
      }
    } catch (e) {
      print('Registration failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed. Please try again.')),
      );
    }
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

                // Signup with Google Button (RegisterScreen)
                SignInButton(
                  Buttons.Google,
                  onPressed: signUpWithGoogle,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  text: "Sign up with Google",  // Correct text for RegisterScreen
                ),

                SizedBox(height: 20),

                // Email/Password Register
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
                  onPressed: registerWithEmail,
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    backgroundColor: Color(0xFF9C7F46), // Golden color
                  ),
                  child: Text('Sign up with Email', style: TextStyle(fontSize: 18, color: Colors.white)),
                ),

                SizedBox(height: 20),

                // Already have an account? Login link
                GestureDetector(
                  onTap: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),  // Navigating to LoginScreen
                    );
                  },
                  child: Text(
                    "Already have an account? Login",
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
