import 'dart:convert';
import 'dart:typed_data';

import 'app_logger.dart';

import 'package:core/domain/exceptions/string_exception.dart';

class StringConvert {
  static const String separatorPattern = r'[ ,;]+';

  static String? writeEmptyToNull(String text) {
    if (text.isEmpty) return null;
    return text;
  }

  static String writeNullToEmpty(String? text) {
    return text ?? '';
  }

  static List<String> extractStrings(String input) {
    try {
      // Check if the input is URL encoded
      if (input.contains('%')) {
        input = Uri.decodeComponent(input); // Decode URL encoding
      }

      // Check if the input is Base64 encoded
      if (input.length % 4 == 0 && RegExp(r'^[A-Za-z0-9+/=]+$').hasMatch(input)) {
        input = utf8.decode(base64.decode(input)); // Decode Base64 encoding
      }

      final RegExp separator = RegExp(separatorPattern);
      final listStrings = input
          .replaceAll('\n', ' ')
          .split(separator)
          .where((value) => value.trim().isNotEmpty)
          .toList();
      log('StringConvert::extractStrings:listStrings = $listStrings');
      return listStrings;
    } catch (e) {
      return [];
    }
  }

  static String decodeFromBytes(
    Uint8List bytes, {
    required String? charset,
    bool isHtml = false,
  }) {
    if (isHtml) {
      return utf8.decode(bytes);
    } else if (charset == null) {
      throw const NullCharsetException();
    } else if (charset.toLowerCase().contains('utf-8')) {
      return utf8.decode(bytes);
    } else if (charset.toLowerCase().contains('latin')) {
      return latin1.decode(bytes);
    } else if (charset.toLowerCase().contains('ascii')) {
      return ascii.decode(bytes);
    } else {
      throw const UnsupportedCharsetException();
    }
  }
}
