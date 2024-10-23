import 'package:sanitize_html/sanitize_html.dart';

class SanitizeHtml {
  String process({
    required String inputHtml,
    List<String>? allowAttributes,
    List<String>? allowTags,
    List<String>? allowClassNames,
  }) {
    final outputHtml = sanitizeHtml(
      inputHtml,
      allowAttributes: allowAttributes,
      allowTags: allowTags,
      allowClassName: (className) =>
        allowClassNames?.contains(className.toLowerCase()) == true
    );
    return outputHtml;
  }
}