import 'package:sanitize_html/sanitize_html.dart';

class SanitizeHtml {
  String process({
    required String inputHtml,
    List<String>? allowAttributes,
    List<String>? allowTags,
  }) {
    final outputHtml = sanitizeHtml(
      inputHtml,
      allowAttributes: allowAttributes,
      allowTags: allowTags,
    );
    return outputHtml;
  }
}