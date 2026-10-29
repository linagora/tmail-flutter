import 'package:core/presentation/utils/html_transformer/editor_html_sanitizer.dart';
import 'package:html/parser.dart' show parseFragment;

/// HTML loaded from the server and the sanitized copy given to the
/// editor. While the editor still holds that copy, saving keeps the stored one,
/// unless that copy shows nothing.
class StoredEditorHtml {
  StoredEditorHtml(this.raw) : sanitized = EditorHtmlSanitizer.sanitize(raw);

  final String raw;
  final String sanitized;

  // trim: the mobile editor template wraps its content in newlines.
  String resolveForSave(String editorSignature) =>
      editorSignature.trim() == sanitized.trim() && _sanitizedShowsContent
          ? raw
          : EditorHtmlSanitizer.sanitize(editorSignature);

  bool get _sanitizedShowsContent {
    final fragment = parseFragment(sanitized);
    for (final style in fragment.querySelectorAll('style')) {
      style.remove();
    }
    return fragment.text?.trim().isNotEmpty == true ||
        fragment.querySelector('img') != null;
  }
}
