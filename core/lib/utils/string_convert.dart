import 'dart:convert';
import 'dart:typed_data';

import 'package:core/utils/app_logger.dart';
import 'package:core/domain/exceptions/string_exception.dart';
import 'package:core/utils/mail/named_address.dart';
import 'package:flutter/widgets.dart' show visibleForTesting;
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http_parser/http_parser.dart';

class StringConvert {
  // Change the pattern to include newlines directly to avoid the .replaceAll() step
  static const String emailSeparatorPattern = r'[ ,;\n\r\t]+';

  // ReDoS-safe regex patterns as static final
  static final _base64ValidationRegex = RegExp(r'^[A-Za-z0-9+/=]+$');
  static final _mdSeparatorRegex = RegExp(
    r'^\|?(?:[ \t]*:?-+:?[ \t]*\|)+[ \t]*:?-+:?[ \t]*\|?$',
    multiLine: false,
  );
  static final _asciiArtRegex = RegExp(r'[+\-|/\\=]');
  static final _namedAddressRegex = RegExp(r'''(?:(?:"([^"]+)"|'([^']+)')\s*)?<([^>]+)>''');

  @visibleForTesting
  static RegExp get base64ValidationRegex => _base64ValidationRegex;

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
      // 1. URL Decoding
      if (input.contains('%')) {
        input = Uri.decodeComponent(input);
      }

      // 2. Base64 Check - Using a non-regex check first is faster
      if (input.length % 4 == 0 && !input.contains(' ')) {
        // Only run regex if basic length/whitespace checks pass
        if (_base64ValidationRegex.hasMatch(input)) {
          try {
            input = utf8.decode(base64.decode(input));
          } catch (_) {
            // Ignore if decoding fails
          }
        }
      }

      // 3. Optimized Split
      // We use the pattern directly and skip the redundant .replaceAll() and .trim()
      final RegExp separator = RegExp(separatorPattern);
      final listStrings = input
          .split(separator)
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

  static String getContentOriginal(String content) {
    try {
      final emailDocument = parse(content);
      final contentOriginal = emailDocument.body?.innerHtml ?? content;
      return contentOriginal;
    } catch (e) {
      logError('StringConvert::getContentOriginal:Exception = $e');
      return content;
    }
  }

  /// Checks if the given text is a table (supports Markdown or ASCII art format).
  static bool isTextTable(String text) {
    final lines =
        text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.length < 2) return false;

    bool isMarkdown = false;
    bool allLinesHaveAscii = true;

    for (final line in lines) {
      if (!isMarkdown && _mdSeparatorRegex.hasMatch(line)) {
        isMarkdown = true;
      }
      if (allLinesHaveAscii && !_asciiArtRegex.hasMatch(line)) {
        allLinesHaveAscii = false;
      }
      // Early exit if we found a table but also know it's not ASCII art
      if (isMarkdown && !allLinesHaveAscii) break;
    }

    return isMarkdown || (allLinesHaveAscii && lines.length >= 2);
  }

  static List<NamedAddress> extractNamedAddresses(String input) {
    try {
      if (input.contains('%')) {
        input = Uri.decodeComponent(input);
      }

      if (input.length % 4 == 0 && _base64ValidationRegex.hasMatch(input)) {
        try {
          input = utf8.decode(base64.decode(input));
        } catch (_) {}
      }

      input = input.replaceAll('\n', ' ');
      final results = <NamedAddress>[];

      int currentIndex = 0;
      // Use a for-in loop directly on the iterable to save memory
      for (final match in _namedAddressRegex.allMatches(input)) {
        if (match.start > currentIndex) {
          final between = input.substring(currentIndex, match.start);
          results.addAll(_splitPlainAddresses(between, emailSeparatorPattern));
        }

        final name = match.group(1) ?? match.group(2) ?? '';
        final email = match.group(3) ?? '';
        results.add(NamedAddress(name: name.trim(), address: email.trim()));

        currentIndex = match.end;
      }

      if (currentIndex < input.length) {
        final tail = input.substring(currentIndex);
        results.addAll(_splitPlainAddresses(tail, emailSeparatorPattern));
      }
      log('StringConvert::extractNamedAddresses:results = $results');
      return results;
    } catch (_) {
      return [];
    }
  }

  static List<NamedAddress> _splitPlainAddresses(
    String input,
    String emailSeparatorPattern,
  ) {
    final separator = RegExp(emailSeparatorPattern);
    return input
        .split(separator)
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .map((e) => NamedAddress(name: '', address: e))
        .toList();
  }

  static String convertHtmlContentToTextContent(String htmlContent) {
    try {
      final document = parse(htmlContent);

      // Each paragraph is surrounded by block tags so we add a /n for each block tag
      // Even <br> are surrounded by block tags so we can ignore <br> and treat them
      // as paragraph
      const blockTags = 'p, div, li, section, blockquote, article, header, footer, h1, h2, h3, h4, h5, h6';

      document.querySelectorAll(blockTags).forEach((element) {
        element.append(Text('\n'));
      });

      final String textContent = document.body?.text ?? '';

      return textContent.trim();
    } catch (e) {
      logError('StringConvert::convertHtmlContentToTextContent:Exception = $e');
      return htmlContent.trim();
    }
  }

  static String convertTextContentToHtmlContent(String textContent) {
    // Escape HTML entities first to prevent interpretation as HTML
    final escapedContent = textContent
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');

    final htmlContent = escapedContent.replaceAll('\n', '<br>');

    return '<div>$htmlContent</div>';
  }
}