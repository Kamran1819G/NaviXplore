import 'package:flutter/material.dart';

// Light Mode Theme
ThemeData lightMode = ThemeData(
  useMaterial3: true,
  // ** Primary Color **
  primaryColor: Colors.deepOrange.shade300,
  primarySwatch: Colors.deepOrange,
  // ** Background Colors **
  scaffoldBackgroundColor: Colors.white,
  canvasColor: Colors.white, // For dialogs, popups
);

// Dark Mode Theme
ThemeData darkMode = ThemeData(
  primaryColor: Colors.deepOrange.shade300,
  scaffoldBackgroundColor: Colors.grey.shade700,
);
