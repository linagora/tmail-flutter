import 'dart:convert';
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/sanitize_html.dart';

class StandardizeHtmlSanitizingTransformers extends TextTransformer {
  static final SanitizeHtml _sanitizer = SanitizeHtml();

  const StandardizeHtmlSanitizingTransformers();

  @override
  String process(String text, HtmlEscape htmlEscape) {
    if (text.isEmpty) return '';
    return _sanitizer.process(inputHtml: text);
  }
}
