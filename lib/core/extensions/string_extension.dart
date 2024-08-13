import 'package:flutter/material.dart';

extension StringExtension on String {
  String get capitalize => "${this[0].toUpperCase()}${substring(1)}";

  Color fromHex() {
    String hex = toUpperCase().replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }
}
