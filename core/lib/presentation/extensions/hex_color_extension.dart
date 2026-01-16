import 'package:flutter/material.dart';

extension HexColorExtension on String {
  Color toColor({Color fallback = Colors.transparent}) {
    try {
      final hex = replaceAll('#', '');

      if (hex.length != 6 && hex.length != 8) {
        return fallback;
      }

      final fullHex = hex.length == 6 ? 'FF$hex' : hex;
      return Color(int.parse(fullHex, radix: 16));
    } catch (_) {
      return fallback;
    }
  }
}
