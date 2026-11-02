import 'package:core/utils/html/editor_script/web_editor_script.dart';

/// Summernote leaves code view on `Escape` by itself and writes the raw
/// textarea HTML into the editable, skipping the sanitizer the app runs when
/// code view is left with the Embed code button. Swallowing that `Escape`
/// before it reaches the textarea keeps the app as the only way out.
final class CodeViewEscapeGuardScript implements WebEditorScript {
  const CodeViewEscapeGuardScript();

  @override
  String get name => 'registerCodeViewEscapeGuard';

  @override
  String get script => r'''
      (() => {
        const root = document.documentElement;
        if (!root || root.dataset.codeViewEscapeGuardAttached) return;
        root.dataset.codeViewEscapeGuardAttached = 'true';

        document.addEventListener('keyup', (event) => {
          const isEscape = event.key === 'Escape' || event.keyCode === 27;
          const target = event.target;
          if (!isEscape || !target || typeof target.closest !== 'function') {
            return;
          }
          if (!target.closest('.note-codable')) return;
          event.stopPropagation();
        }, true);
      })();''';
}
