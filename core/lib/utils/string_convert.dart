import 'dart:convert';
import 'dart:typed_data';

import 'package:core/utils/app_logger.dart';
import 'package:core/domain/exceptions/string_exception.dart';

class StringConvert {
  static const String emailSeparatorPattern = r'[ ,;]+';

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

  static List<String> extractStrings(String input, String separatorPattern) {
    try {
      // Check if the input is URL encoded
      if (input.contains('%')) {
        input = Uri.decodeComponent(input); // Decode URL encoding
      }

      // Efficient Base64 validation: Check length and minimal regex match
      if (input.length % 4 == 0 && input.contains(RegExp(r'^[A-Za-z0-9+/=]+$'))) {
        try {
          input = utf8.decode(base64.decode(input)); // Decode Base64 encoding
        } catch (_) {
          // Ignore if decoding fails
        }
      }

      final RegExp separator = RegExp(separatorPattern);
      final listStrings = input
          .replaceAll('\n', ' ')
          .split(separator)
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
      log('StringConvert::extractStrings:listStrings = $listStrings');
      return listStrings;
    } catch (e) {
      return [];
    }
  }

  static List<String> extractEmailAddress(String input) =>
      extractStrings(input, emailSeparatorPattern);

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

  static String toUrlScheme(String hostScheme) {
    return '$hostScheme://';
  }
}
