import 'package:flutter/material.dart';

const Color pastelBackground = Color(0xFFFFF1F3); // blush pink
const Color pastelAccentColor = Color(0xFFD8A7B1); // mauve/rose
const Color pastelCardColor = Color(0xFFFFF8F0); // cream
const Color textBrown = Color(0xFF5D4037); // topli braon
const Color goldColor = Color(0xFFFFD700); // zlatna
const Color darkBackground = Color(0xFF2C2C2C); // tamna pozadina za header/footer

// 🎨 Dodatne pastelne nijanse u stilu palete šminke
const Color pastelPink = Color(0xFFFFD1DC);
const Color pastelMauve = Color(0xFFE0B0FF);
const Color pastelPeach = Color(0xFFFFDAB9);
const Color pastelLavender = Color(0xFFE6E6FA);
const Color pastelGrey = Color(0xFFD3D3D3);
const Color pastelMint = Color(0xFFAAF0D1);
const Color pastelRose = Color(0xFFF4C2C2); // 🌹 Dodata ružičasta nijansa

const Color goldenAccent = goldColor;
const Color darkFooterBackground = darkBackground;

// Aliases za backward kompatibilnost
const Color pastelBlush = pastelBackground;
const Color pastelTextBrown = textBrown;
const Color pastelCream = pastelCardColor;

final ThemeData steamyTheme = ThemeData(
  scaffoldBackgroundColor: pastelBackground,
  fontFamily: 'Lora',
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: textBrown,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      color: textBrown,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      color: textBrown,
    ),
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: darkBackground,
    iconTheme: IconThemeData(color: goldColor),
    titleTextStyle: TextStyle(
      color: goldColor,
      fontFamily: 'Lora',
      fontSize: 22,
      fontWeight: FontWeight.bold,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: darkBackground,
    selectedItemColor: goldColor,
    unselectedItemColor: Colors.white70,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    secondary: pastelAccentColor,
  ),
);
