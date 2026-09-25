import 'package:core/presentation/utils/html_transformer/editor_html_sanitizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EditorHtmlSanitizer.sanitize', () {
    test('SHOULD remove script elements', () {
      final out = EditorHtmlSanitizer.sanitize('<p>Hi</p><script>parent.postMessage(1, "*")</script>');

      expect(out, contains('Hi'));
      expect(out.toLowerCase(), isNot(contains('<script')));
    });

    test('SHOULD remove inline event handlers', () {
      final out = EditorHtmlSanitizer.sanitize('<img src="x" onerror="parent.postMessage(1, \'*\')">');

      expect(out.toLowerCase(), isNot(contains('onerror')));
    });

    test('SHOULD remove nested frames and meta refresh', () {
      final out = EditorHtmlSanitizer.sanitize(
        '<meta http-equiv="refresh" content="0;url=https://example.com">'
        '<iframe srcdoc="&lt;script&gt;alert(1)&lt;/script&gt;"></iframe><p>Body</p>',
      );

      expect(out, contains('Body'));
      expect(out.toLowerCase(), isNot(contains('<meta')));
      expect(out.toLowerCase(), isNot(contains('<iframe')));
    });

    test('SHOULD keep regular formatting and inline image attributes', () {
      final out = EditorHtmlSanitizer.sanitize(
        '<div><b>bold</b> <a href="https://example.com">link</a>'
        '<img src="data:image/png;base64,AAAA" data-mimetype="image/png"></div>',
      );

      expect(out, contains('<b>bold</b>'));
      expect(out, contains('href="https://example.com"'));
      expect(out, contains('data-mimetype="image/png"'));
    });

    test('SHOULD keep contenteditable on Drive link cards only', () {
      final out = EditorHtmlSanitizer.sanitize(
        '<a class="tmail-file-link-card" contenteditable="false" href="https://example.com">file</a>'
        '<div contenteditable="true">x</div>',
      );

      expect(out, contains('contenteditable="false"'));
      expect(out, isNot(contains('contenteditable="true"')));
    });

    test('SHOULD return empty content unchanged', () {
      expect(EditorHtmlSanitizer.sanitize(''), '');
      expect(EditorHtmlSanitizer.sanitize('   '), '   ');
    });
  });
}
