
import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/sanitize_autolink_filter.dart';
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';

class SanitizeAutolinkHtmlTransformers extends TextTransformer {

  const SanitizeAutolinkHtmlTransformers();

  @override
  String process(String text, HtmlEscape htmlEscape) => SanitizeAutolinkFilter(htmlEscape).process(text);
}