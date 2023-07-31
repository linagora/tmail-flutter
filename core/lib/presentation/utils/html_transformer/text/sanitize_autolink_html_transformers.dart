
import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/sanitize_autolink_filter.dart';
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';

class SanitizeAutolinkHtmlTransformers extends TextTransformer {

  final HtmlEscape htmlEscape;

  SanitizeAutolinkHtmlTransformers(this.htmlEscape);

  @override
  String process(String text) => SanitizeAutolinkFilter(htmlEscape).process(text);
}