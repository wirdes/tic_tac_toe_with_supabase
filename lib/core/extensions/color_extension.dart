import 'package:flutter/material.dart';

extension ColorExtension on Color {
  String toHex() {
    return '#${red.toRadixString(16).padLeft(2, '0')}${green.toRadixString(16).padLeft(2, '0')}${blue.toRadixString(16).padLeft(2, '0')}';
  }

  Color getTextColor() {
    double luminance = computeLuminance();
    return luminance < 0.5 ? Colors.white : Colors.black;
  }
}
