import 'dart:js_interop';

import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:web/web.dart' as web;

import 'marionette_composer_schema.dart';

const _editableSelector = 'div.note-editable';

void registerComposerExtensions() {
  registerMarionetteExtension(
    name: setBodyExtensionName,
    description: setBodyDescription,
    inputSchema: setBodyInputSchema,
    callback: (params) async {
      final text = params['text'];
      if (text == null) return missingTextParam();

      final editable = _findEditable();
      if (editable == null) return noComposerOpen();

      _replaceBody(editable, text);
      return MarionetteExtensionResult.success({'body': editable.innerText});
    },
  );

  registerMarionetteExtension(
    name: getBodyExtensionName,
    description: getBodyDescription,
    callback: (params) async {
      final editable = _findEditable();
      if (editable == null) return noComposerOpen();
      return MarionetteExtensionResult.success({
        'text': editable.innerText,
        'html': (editable.innerHTML as JSString).toDart,
      });
    },
  );
}

web.HTMLElement? _findEditable() {
  final iframes = web.document.querySelectorAll('iframe');
  for (var i = 0; i < iframes.length; i++) {
    final iframe = iframes.item(i) as web.HTMLIFrameElement;
    final editable = iframe.contentDocument?.querySelector(_editableSelector);
    if (editable != null) return editable as web.HTMLElement;
  }
  return null;
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
    ..dispatchEvent(web.InputEvent('input', web.InputEventInit(bubbles: true)));
}
