import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';

class PersistPreformattedTextTransformer extends TextTransformer {
  const PersistPreformattedTextTransformer();

  @override
  String process(String text, HtmlEscape htmlEscape) {
    return '<pre>$text</pre>';
  }
}