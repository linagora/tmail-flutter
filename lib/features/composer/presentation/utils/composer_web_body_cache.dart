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
  // Stays set after any code-view write until setTrusted, so a late editor
  // change after a rebuild read cannot land raw HTML as trusted.
  bool _codeViewTouched = false;

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
    _codeViewTouched = false;
  }

  /// Content reported by the editor, raw whenever code view is on.
  ///
  /// Once code view has written to it, later editor changes stay marked until
  /// the app replaces the body. A change event can land after code view is left
  /// and after a rebuild has already read the sanitized snapshot.
  void onEditorChange(String? body, {required bool inCodeView}) {
    _body = body;
    if (inCodeView) {
      _codeViewTouched = true;
    }
    if (_codeViewTouched) {
      _needsSanitizing = true;
    }
  }
}
