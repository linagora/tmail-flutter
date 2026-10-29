import 'package:flutter_test/flutter_test.dart';
import 'package:core/presentation/utils/html_transformer/editor_html_sanitizer.dart';
import 'package:core/presentation/utils/html_transformer/stored_editor_html.dart';

void main() {
  const raw = '<p>Hi</p><script>x</script>';

  group('StoredEditorHtml', () {
    test('sanitized equals the sanitizer output of the raw signature', () {
      expect(StoredEditorHtml(raw).sanitized, EditorHtmlSanitizer.sanitize(raw));
    });

    test('resolveForSave returns the raw signature when the editor is untouched', () {
      final stored = StoredEditorHtml(raw);

      expect(stored.resolveForSave(stored.sanitized), raw);
    });

    test('resolveForSave sanitizes a signature edited in the editor', () {
      final result = StoredEditorHtml(raw).resolveForSave('<p>Bye</p><script>x</script>');

      expect(result, EditorHtmlSanitizer.sanitize('<p>Bye</p><script>x</script>'));
      expect(result, isNot(contains('<script')));
    });

    // A stored signature made only of active content shows as an empty
    // editor. Saving that empty editor must not write the active content
    // back, otherwise the user can never remove it.
    test('resolveForSave does not keep a raw signature that sanitizes to nothing', () {
      const activeOnly = '<iframe srcdoc="<script>top.x=1</script>"></iframe>';
      final stored = StoredEditorHtml(activeOnly);

      final result = stored.resolveForSave(stored.sanitized);

      expect(stored.sanitized.trim(), isEmpty);
      expect(result, isNot(contains('<iframe')));
      expect(result, isNot(contains('<script')));
    });

    test('resolveForSave does not keep a raw signature whose wrapper sanitizes to an empty element', () {
      final stored = StoredEditorHtml('<div><script>alert(1)</script></div>');

      expect(stored.resolveForSave(stored.sanitized), stored.sanitized);
    });

    test('resolveForSave keeps an untouched raw signature made only of an image', () {
      const imageOnly = '<div><img src="https://example.com/logo.png" onerror="x()"></div>';
      final stored = StoredEditorHtml(imageOnly);

      expect(stored.resolveForSave(stored.sanitized), imageOnly);
    });

    test('resolveForSave does not keep a raw signature that sanitizes to only a style element', () {
      final stored = StoredEditorHtml('<div><style>p{color:red}</style><script>x</script></div>');

      expect(stored.resolveForSave(stored.sanitized), isNot(contains('<script')));
    });

    test('resolveForSave keeps the raw signature when the mobile editor wraps it in newlines', () {
      final stored = StoredEditorHtml(raw);

      expect(stored.resolveForSave('\n${stored.sanitized}\n'), raw);
    });
  });
}
