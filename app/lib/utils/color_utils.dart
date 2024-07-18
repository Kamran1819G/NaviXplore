import 'package:flutter/material.dart';

// Function to convert hex color code to Color object
Color hexToColor(String code) {
  return Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}
