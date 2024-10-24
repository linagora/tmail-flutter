import 'package:sanitize_html/sanitize_html.dart';

import '../../../utils/app_logger.dart';

class SanitizeHtml {
  String process({
    required String inputHtml,
    List<String>? allowAttributes,
    List<String>? allowTags,
  }) {
    log('SanitizeHtml::process:inputHtml = $inputHtml');
    final outputHtml = sanitizeHtml(
      inputHtml,
      allowAttributes: allowAttributes,
      allowTags: allowTags,
    );
    log('SanitizeHtml::process:outputHtml = $outputHtml');
    return outputHtml;
  }
}