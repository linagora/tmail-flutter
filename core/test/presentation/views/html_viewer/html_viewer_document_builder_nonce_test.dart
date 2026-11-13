import 'package:core/presentation/views/html_viewer/html_viewer_document_builder.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const nonce = 'abcDEF123+/=_-';
  const emailScript = '<p>Hi</p><script>alert(1)</script>';

  test('stamps every tmail script tag and leaves a script in the email content', () {
    final html = _document(emailScript, nonce);
    final quoteHtml = _document(
      '<div><blockquote><p>quoted</p></blockquote></div>',
      nonce,
      quoteToggle: true,
    );

    expect(html, contains(emailScript));
    final touchHtml = _document(emailScript, nonce, touch: true);
    expect(touchHtml, contains(emailScript));
    for (final tag in _scriptOpenTags('$html\n$touchHtml')) {
      if (tag == '<script>') continue;
      expect(tag, contains('nonce="$nonce"'), reason: tag);
    }
    expect(_scriptOpenTags(html).where((tag) => tag == '<script>'), hasLength(1));
    expect(_scriptOpenTags(quoteHtml), isNotEmpty);
    for (final tag in _scriptOpenTags(quoteHtml)) {
      expect(tag, contains('nonce="$nonce"'), reason: tag);
    }
  });

  test('null or invalid nonce leaves the document unchanged', () {
    final baseline = _document(emailScript, null);
    expect(_document(emailScript, null), baseline);
    expect(_document(emailScript, ''), baseline);
    expect(_document(emailScript, 'bad nonce'), baseline);
  });
}

String _document(String content, String? scriptNonce, {bool quoteToggle = false, bool touch = false}) =>
    HtmlViewerDocumentBuilder.buildWebDocument(
      HtmlWebViewerDocumentInput(
        content: content,
        viewId: 'view1',
        widthContent: 640,
        minHeight: 100,
        minWidth: 200,
        enableQuoteToggle: quoteToggle,
        hasMailtoDelegate: true,
        hasHyperLinkAction: true,
        hasScrollController: true,
        hasKeyboardShortcutAction: true,
        useLinkTooltipOverlay: true,
        isWebTouchDevice: touch,
        isWebDesktop: !touch,
        scriptNonce: scriptNonce,
      ),
    );

Iterable<String> _scriptOpenTags(String html) =>
    RegExp(r'<script\b[^>]*>').allMatches(html).map((match) => match.group(0)!);
