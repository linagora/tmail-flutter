import 'dart:convert';
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/sanitize_html.dart';

class StandardizeHtmlSanitizingTransformers extends TextTransformer {

  static const List<String> mailAllowedHtmlAttributes = [
    'style',
    'public-asset-id',
    'data-filename',
    'bgcolor',
    'id',
    'class',
  ];

  static const List<String> mailAllowedHtmlTags = [
    'font',
    'u',
    'center',
    'style',
    'body',
    'section',
    'google-sheets-html-origin',
    'colgroup',
    'col',
    'nav',
    'main',
    'footer',
  ];

  const StandardizeHtmlSanitizingTransformers();

  @override
  String process(String text, HtmlEscape htmlEscape) =>
    SanitizeHtml().process(
      inputHtml: text,
      allowAttributes: mailAllowedHtmlAttributes,
      allowTags: mailAllowedHtmlTags,
    );
}
