import 'dart:convert';
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/sanitize_html.dart';

class StandardizeHtmlSanitizingTransformers extends TextTransformer {

  static const List<String> mailAllowedHtmlAttributes = [
    'style',
    'public-asset-id',
    'data-filename',
    'bgcolor',
  ];

  static const List<String> mailAllowedHtmlTags = [
    'font',
    'u',
    'mcourbo@linagora.com',
    'center',
  ];

  static const List<String> mailAllowedHtmlClassNames = [
    'tmail-signature',
    'tmail-signature-blocked',
    'tmail-signature-button',
    'tmail-signature-content',
    'tmail_signature_prefix',
  ];

  const StandardizeHtmlSanitizingTransformers();

  @override
  String process(String text, HtmlEscape htmlEscape) =>
    SanitizeHtml().process(
      inputHtml: text,
      allowAttributes: mailAllowedHtmlAttributes,
      allowTags: mailAllowedHtmlTags,
      allowClassNames: mailAllowedHtmlClassNames,
    );
}
