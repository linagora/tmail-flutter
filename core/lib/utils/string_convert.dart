import 'dart:convert';

import 'package:core/utils/app_logger.dart';

class StringConvert {
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
}
