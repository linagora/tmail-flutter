import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/base/text_transformer.dart';
import 'package:core/presentation/utils/html_transformer/sanitize_autolink_filter.dart';

/// A text transformer that sanitizes autolinks while preserving HTML markup.
///
/// Delegates to [SanitizeAutolinkFilter] with `escapeHtml: false`, meaning
/// HTML tags in the input are preserved as-is rather than being escaped.
/// This allows rich-text content (e.g. calendar event descriptions) to render
/// as formatted HTML.
///
/// **Security**: This transformer does NOT provide XSS protection on its own.
/// It must be followed by [StandardizeHtmlSanitizingTransformers] or equivalent
/// to strip dangerous elements, attributes, and JavaScript.
class SanitizeAutolinkUnescapeHtmlTransformer extends TextTransformer {
  const SanitizeAutolinkUnescapeHtmlTransformer();

  /// Sanitizes autolinks in [text] without HTML-escaping the surrounding content.
  ///
  /// [htmlEscape] is forwarded to [SanitizeAutolinkFilter] for building link
  /// tags, but the surrounding text content is preserved as-is (`escapeHtml: false`).
  @override
  String process(String text, HtmlEscape htmlEscape) {
    return SanitizeAutolinkFilter(htmlEscape, escapeHtml: false).process(text);
  }
}