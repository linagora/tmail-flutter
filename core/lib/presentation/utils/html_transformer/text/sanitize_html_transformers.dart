
import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/utils/app_logger.dart';

class SanitizeHtmlTransformers extends TextTransformer {

  const SanitizeHtmlTransformers();

  @override
  String process(String text) {
    final htmlEncoded = const HtmlEscape().convert(text);
    log('HtmlSanitizerTransformers::process:htmlEncoded: $htmlEncoded');
    return htmlEncoded;
  }
}