import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';

/// A sanitizer regression that loses every table.
class DropTablesTransformer extends TextTransformer {
  const DropTablesTransformer();

  @override
  String process(String text, HtmlEscape htmlEscape) =>
      text.replaceAll(RegExp(r'<table[\s\S]*?</table>', caseSensitive: false), '');
}
