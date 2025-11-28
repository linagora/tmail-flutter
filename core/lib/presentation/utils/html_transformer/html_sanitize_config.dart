import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:core/utils/app_logger.dart';

class HtmlSanitizeConfig {
  /// Safely load list of HTML tags from `EMAIL_HTML_TAGS_TO_PRESERVE`
  static List<String> loadPreservedHtmlTags() {
    try {
      final raw = dotenv.get('EMAIL_HTML_TAGS_TO_PRESERVE', fallback: '');

      if (raw.trim().isEmpty) {
        return const [];
      }

      return raw
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toSet()
          .toList(growable: false);
    } catch (e) {
      logError('HtmlSanitizeConfig::loadPreservedHtmlTags:Exception = $e');
      return const [];
    }
  }
}
