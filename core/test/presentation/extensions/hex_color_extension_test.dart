import 'package:core/presentation/extensions/hex_color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HexColorExtension.toColor', () {
    test('should convert 6-char hex (#RRGGBB) to Color with default alpha FF',
        () {
      final color = "#FF0000".toColor();
      expect(color, const Color(0xFFFF0000));
    });

    test('should convert 8-char hex (#AARRGGBB) correctly', () {
      final color = "#80FF0000".toColor();
      expect(color, const Color(0x80FF0000));
    });

    test('should handle string without # prefix', () {
      final color = "00FF00".toColor();
      expect(color, const Color(0xFF00FF00));
    });

    test('should return fallback when hex is invalid', () {
      const fallback = Colors.blue;
      final color = "INVALID".toColor(fallback: fallback);
      expect(color, fallback);
    });

    test('should return fallback when hex contains non-hex characters', () {
      const fallback = Colors.red;
      final color = "#GGHHHH".toColor(fallback: fallback);
      expect(color, fallback);
    });

    test('should return fallback when hex length is unsupported', () {
      const fallback = Colors.orange;
      final color = "#FFF".toColor(fallback: fallback);
      expect(color, fallback);
    });

    test('should return fallback for empty string', () {
      const fallback = Colors.purple;
      final color = "".toColor(fallback: fallback);
      expect(color, fallback);
    });

    test('should convert lowercase hex', () {
      final color = "#ff0000".toColor();
      expect(color, const Color(0xFFFF0000));
    });

    test('should convert mixed-case hex', () {
      final color = "#Ff00Ff".toColor();
      expect(color, const Color(0xFFFf00Ff));
    });
  });
}
