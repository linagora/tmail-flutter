import 'dart:convert';

import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

import 'marionette_composer_schema.dart';

void registerComposerExtensions() {
  registerMarionetteExtension(
    name: setBodyExtensionName,
    description: setBodyDescription,
    inputSchema: setBodyInputSchema,
    callback: (params) async {
      final text = params['text'];
      if (text == null) return missingTextParam();

      final result = await _evaluate(_setBodyScript(text));
      if (result == null) return noComposerOpen();
      return MarionetteExtensionResult.success({'body': result.toString()});
    },
  );

  registerMarionetteExtension(
    name: getBodyExtensionName,
    description: getBodyDescription,
    callback: (params) async {
      final result = await _evaluate(_getBodyScript);
      if (result == null) return noComposerOpen();
      final body = jsonDecode(result.toString()) as Map<String, dynamic>;
      return MarionetteExtensionResult.success(body);
    },
  );
}

Future<dynamic> _evaluate(String source) async {
  final editorApi = getBinding<RichTextMobileTabletController>()?.htmlEditorApi;
  if (editorApi == null) return null;
  return editorApi.webViewController.evaluateJavascript(source: source);
}

String _setBodyScript(String text) => '''
(() => {
  const editor = document.getElementById('editor');
  if (!editor) return null;
  const signature = editor.querySelector('div.tmail-signature');
  editor.replaceChildren();
  for (const line of ${jsonEncode(text.split('\n'))}) {
    const paragraph = document.createElement('div');
    if (line) {
      paragraph.textContent = line;
    } else {
      paragraph.appendChild(document.createElement('br'));
    }
    editor.appendChild(paragraph);
  }
  if (signature) editor.appendChild(signature);
  editor.dispatchEvent(new Event('input', { bubbles: true }));
  return editor.innerText;
})();
''';

const _getBodyScript = '''
(() => {
  const editor = document.getElementById('editor');
  if (!editor) return null;
  return JSON.stringify({ text: editor.innerText, html: editor.innerHTML });
})();
''';
