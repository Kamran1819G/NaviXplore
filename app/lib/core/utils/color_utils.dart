import 'package:flutter/material.dart';
import 'dart:math';

class ColorUtils {
  static Color hexToColor(String code) {
    String hexCode = code.toUpperCase().replaceAll('#', '');

    // Handling shorthand hex codes e.g. #FFF
    if (hexCode.length == 3) {
      hexCode = hexCode[0] +
          hexCode[0] +
          hexCode[1] +
          hexCode[1] +
          hexCode[2] +
          hexCode[2];
    }
    // Handle alpha values with default to full opacity if not provided.
    if (hexCode.length == 6) {
      hexCode = 'FF' + hexCode;
    }

    return Color(int.parse(hexCode, radix: 16));
  }

  static String colorToHex(Color color, {bool withAlpha = true}) {
    final r = color.red.clamp(0, 255);
    final g = color.green.clamp(0, 255);
    final b = color.blue.clamp(0, 255);
    final a = color.alpha.clamp(0,255);

    if (withAlpha) {
      return '#${a.toRadixString(16).padLeft(2, '0')}${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
    } else {
      return '#${r.toRadixString(16).padLeft(2, '0')}${g.toRadixString(16).padLeft(2, '0')}${b.toRadixString(16).padLeft(2, '0')}';
    }
  }

  static bool isColorLight(Color color) {
    // Calculate perceived brightness using the standard formula
    final brightness =
        ((color.red * 299) + (color.green * 587) + (color.blue * 114)) / 1000;
    return brightness > 155; // You can adjust this threshold.
  }
}