import 'package:core/utils/external_link_policy.dart';
import 'package:sanitize_html/sanitize_html.dart';

class SanitizeHtml {
  String process({
    required String inputHtml,
    List<String>? allowAttributes,
    List<String>? allowTags,
  }) {
    final outputHtml = sanitizeHtml(
      inputHtml,
      allowLinkHref: ExternalLinkPolicy.canKeepInContent,
      allowAttributes: allowAttributes,
      allowTags: allowTags,
    );
    return outputHtml;
  }
}