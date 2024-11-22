import 'dart:convert';

import 'package:core/utils/app_logger.dart';

class StringConvert {
  static const String separatorPattern = r'[ ,;]+';

  static String? writeEmptyToNull(String text) {
    if (text.isEmpty) return null;
    return text;
  }

  static String writeNullToEmpty(String? text) {
    return text ?? '';
  }

  static String decodeBase64ToString(String text) {
    try {
      return utf8.decode(base64Decode(text));
    } catch (e) {
      logError('StringConvert::decodeBase64ToString:Exception = $e');
      return text;
    }
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
}
