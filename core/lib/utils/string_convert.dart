import 'dart:convert';
import 'dart:typed_data';

import 'package:core/utils/app_logger.dart';
import 'package:core/domain/exceptions/string_exception.dart';
import 'package:http_parser/http_parser.dart';

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

  static Uint8List convertBase64ImageTagToBytes(String base64ImageTag) {
    if (!base64ImageTag.contains('base64,')) {
      throw ArgumentError('The string is not valid Base64 data from an <img> tag.');
    }

    final base64Data = base64ImageTag.split(',').last;

    return base64Decode(base64Data);
  }

  static MediaType? getMediaTypeFromBase64ImageTag(String base64ImageTag) {
    try {
      if (!base64ImageTag.startsWith("data:") || !base64ImageTag.contains(";base64,")) {
        return null;
      }

      final mimeType = base64ImageTag.split(";")[0].split(":")[1];
      log('StringConvert::getMediaTypeFromBase64ImageTag:mimeType = $mimeType');
      return MediaType.parse(mimeType);
    } catch (e) {
      logError('StringConvert::getMimeTypeFromBase64ImageTag:Exception = $e');
      return null;
    }
  }
}
