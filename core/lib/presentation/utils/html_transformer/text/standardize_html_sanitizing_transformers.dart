import 'dart:convert';
import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/sanitize_html.dart';
import 'package:core/utils/app_logger.dart';
import 'package:html/parser.dart' show parseFragment;

class StandardizeHtmlSanitizingTransformers extends TextTransformer {
  static const _driveLinkCardClassName = 'tmail-file-link-card';
  static const _contentEditableAttribute = 'contenteditable';

  static final SanitizeHtml _sanitizer = SanitizeHtml();

  final List<String>? allowAttributes;

  const StandardizeHtmlSanitizingTransformers({this.allowAttributes});

  @override
  String process(String text, HtmlEscape htmlEscape) {
    if (text.isEmpty) return '';

    final scopedText = allowAttributes?.contains(_contentEditableAttribute) == true &&
            text.toLowerCase().contains(_contentEditableAttribute)
      ? _stripContentEditableOutsideDriveLinkCard(text)
      : text;

    return _sanitizer.process(
      inputHtml: scopedText,
      allowAttributes: allowAttributes,
    );
  }

  /// The sanitizer's [allowAttributes] allow-list is attribute-name based, so
  /// allowing `contenteditable` preserves it on any element, not only the
  /// Drive link card. Strip it from every element except
  /// `a.tmail-file-link-card` before sanitizing, so the allow-list can only
  /// ever surface it on that card.
  String _stripContentEditableOutsideDriveLinkCard(String html) {
    try {
      final fragment = parseFragment(html);
      for (final element in fragment.querySelectorAll(
        '[$_contentEditableAttribute]',
      )) {
        final isDriveLinkCard =
            element.localName == 'a' &&
            element.classes.contains(_driveLinkCardClassName);
        if (!isDriveLinkCard) {
          element.attributes.remove(_contentEditableAttribute);
        }
      }
      return fragment.outerHtml;
    } catch (e) {
      log('Failed to strip contenteditable attribute from HTML: $e');
      return html;
    }
  }
}
