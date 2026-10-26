import 'package:core/presentation/utils/html_transformer/editor_html_sanitizer.dart';

/// A signature loaded from the server and the sanitized copy given to the
/// editor. While the editor still holds that copy, saving keeps the stored one,
/// unless that copy is empty.
class StoredSignature {
  StoredSignature(this.raw) : sanitized = EditorHtmlSanitizer.sanitize(raw);

  final String raw;
  final String sanitized;

  String resolveForSave(String editorSignature) =>
      editorSignature == sanitized && sanitized.trim().isNotEmpty
          ? raw
          : EditorHtmlSanitizer.sanitize(editorSignature);
}
