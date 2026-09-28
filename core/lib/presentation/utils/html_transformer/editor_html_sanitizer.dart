import 'dart:convert';

import 'package:core/presentation/utils/html_transformer/text/standardize_html_sanitizing_transformers.dart';

/// Sanitizes HTML before it is rendered by the composer editor.
///
/// The editor is a same-origin iframe whose content setter (summernote,
/// jQuery `.html()`) evaluates markup: scripts, inline event handlers,
/// nested frames and meta refresh would run with the application's
/// privileges. `contenteditable` is kept for Drive link cards, as for
/// drafts.
class EditorHtmlSanitizer {
  const EditorHtmlSanitizer._();

  static const StandardizeHtmlSanitizingTransformers _sanitizer =
      StandardizeHtmlSanitizingTransformers(allowAttributes: ['contenteditable']);

  static String sanitize(String html) {
    if (html.trim().isEmpty) return html;
    return _sanitizer.process(html, const HtmlEscape());
  }
}
