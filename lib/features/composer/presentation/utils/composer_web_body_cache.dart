import 'package:tmail_ui_user/features/composer/presentation/utils/composer_code_view_sanitizer.dart';

/// The web composer body, as last reported by the editor or set by the app.
///
/// Send, drafts, print and the editor rebuilt after minimize all read it. Code
/// view hands over raw HTML, so that HTML is sanitized once, on the next read,
/// rather than on every keystroke.
class ComposerWebBodyCache {
  ComposerWebBodyCache({
    ComposerCodeViewSanitizer sanitizer = const ComposerCodeViewSanitizer(),
  }) : _sanitizer = sanitizer;

  final ComposerCodeViewSanitizer _sanitizer;
  String? _body;
  bool _needsSanitizing = false;

  String? read() {
    final body = _body;
    if (_needsSanitizing && body != null) {
      _body = _sanitizer.sanitize(body);
    }
    _needsSanitizing = false;
    return _body;
  }

  /// Content the app built itself (draft, reply quote, signature).
  void setTrusted(String? body) {
    _body = body;
    _needsSanitizing = false;
  }

  /// Content reported by the editor, raw whenever code view is on.
  void onEditorChange(String? body, {required bool inCodeView}) {
    _body = body;
    _needsSanitizing = inCodeView;
  }
}
