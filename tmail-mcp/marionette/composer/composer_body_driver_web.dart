import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'composer_body_driver.dart';

const _editableSelector = 'div.note-editable';

ComposerBodyDriver createComposerBodyDriver() => const ComposerBodyDriverWeb();

/// Drives the Summernote editor rendered inside the composer iframe.
class ComposerBodyDriverWeb implements ComposerBodyDriver {
  const ComposerBodyDriverWeb();

  @override
  Future<ComposerBodyResult> setBody(String text) async {
    return _withSingleEditable((editable) {
      _replaceBody(editable, text);
      return ComposerBodyFound({'body': editable.innerText});
    });
  }

  @override
  Future<ComposerBodyResult> getBody() async {
    return _withSingleEditable((editable) {
      return ComposerBodyFound({
        'text': editable.innerText,
        'html': (editable.innerHTML as JSString).toDart,
      });
    });
  }

  /// Web can show several composers side by side. Acting on the first editor
  /// found could write into the wrong draft, so refuse when it is ambiguous.
  ComposerBodyResult _withSingleEditable(
    ComposerBodyResult Function(web.HTMLElement editable) action,
  ) {
    final editables = _findEditables();
    return switch (editables.length) {
      0 => const ComposerNotFound(),
      1 => action(editables.single),
      _ => const MultipleComposersFound(),
    };
  }

  List<web.HTMLElement> _findEditables() {
    final editables = <web.HTMLElement>[];
    final iframes = web.document.querySelectorAll('iframe');
    for (var i = 0; i < iframes.length; i++) {
      final iframe = iframes.item(i) as web.HTMLIFrameElement;
      final editable = iframe.contentDocument?.querySelector(_editableSelector);
      if (editable != null) editables.add(editable as web.HTMLElement);
    }
    return editables;
  }

  void _replaceBody(web.HTMLElement editable, String text) {
    final document = editable.ownerDocument!;
    final signature = editable.querySelector('div.tmail-signature');
    editable.replaceChildren(''.toJS);
    for (final line in text.split('\n')) {
      final paragraph = document.createElement('div');
      if (line.isEmpty) {
        paragraph.appendChild(document.createElement('br'));
      } else {
        paragraph.textContent = line;
      }
      editable.appendChild(paragraph);
    }
    if (signature != null) editable.appendChild(signature);
    editable
      ..focus()
      ..dispatchEvent(
        web.InputEvent('input', web.InputEventInit(bubbles: true)),
      );
  }
}
