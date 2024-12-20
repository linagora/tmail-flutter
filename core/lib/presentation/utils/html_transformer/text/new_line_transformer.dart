import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';

class NewLineTransformer extends TextTransformer {
  const NewLineTransformer();

  @override
  String process(String text, HtmlEscape htmlEscape) {
    return text
      .replaceAll('\n', '<br>')
      .replaceAll('\r', ' ')
      .replaceAll('\t', '    ');
  }
}