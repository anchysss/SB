import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:steamy_book/screens/home_screen.dart';  // Home screen
import 'package:steamy_book/screens/login_screen.dart'; // Login screen
import 'package:steamy_book/screens/register_screen.dart'; // Register screen
import 'theme.dart';  // Custom theme
import 'firebase_options.dart'; // Firebase configuration (generated file)
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Auth

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the options for the current platform
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Check if the user is already logged in
  User? user = FirebaseAuth.instance.currentUser;

  runApp(SteamyBookApp(initialUser: user));
}

class SteamyBookApp extends StatelessWidget {
  final User? initialUser;

  const SteamyBookApp({super.key, this.initialUser});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Steamy Book',
      debugShowCheckedModeBanner: false,
      theme: steamyTheme,
      initialRoute: initialUser == null ? '/' : '/home',  // Navigate to home if already logged in
      routes: {
        '/': (context) => const LoginScreen(),  // Go to login screen first
        '/home': (context) => const HomeScreen(),  // Home screen route
        '/register': (context) => const RegisterScreen(), // Register screen route
      },
    );
  }
}
