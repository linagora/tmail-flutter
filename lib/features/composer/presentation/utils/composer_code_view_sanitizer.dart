import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';

class ComposerCodeViewSanitizer {
  const ComposerCodeViewSanitizer();

  static const _transformer = StandardizeHtmlSanitizingTransformers(
    allowAttributes: ['contenteditable'],
  );
  static const _htmlEscape = HtmlEscape();

  String sanitize(String html) => _transformer.process(html, _htmlEscape);
}
