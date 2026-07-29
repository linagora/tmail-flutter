import 'package:html/parser.dart';

/// Helpers for complete HTML documents, e.g. the output of
/// `HtmlTransform.transformToHtml`, which always serializes a full
/// `<html><head>…</head><body>…</body></html>` document.
extension HtmlDocumentExtension on String {
  /// Converts a complete HTML document into a fragment insertable into an
  /// editor: the body's inner HTML, prefixed with any `<style>` blocks the
  /// parser hoisted into `<head>` so a stylesheet survives the conversion.
  String toHtmlFragment() {
    final document = parse(this);
    final headStyles = document.head
            ?.getElementsByTagName('style')
            .map((style) => style.outerHtml)
            .join() ??
        '';
    return '$headStyles${document.body?.innerHtml ?? ''}';
  }
}
