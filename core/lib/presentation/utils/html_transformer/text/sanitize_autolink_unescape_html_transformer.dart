import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/sanitize_autolink_filter.dart';

class SanitizeAutolinkUnescapeHtmlTransformer extends TextTransformer {
  const SanitizeAutolinkUnescapeHtmlTransformer();

  @override
  String process(String text, HtmlEscape htmlEscape) {
    return SanitizeAutolinkFilter(htmlEscape, escapeHtml: false).process(text);
  }
}