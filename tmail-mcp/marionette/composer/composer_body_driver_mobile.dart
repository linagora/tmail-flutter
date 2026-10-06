import 'dart:convert';

import 'package:tmail_ui_user/features/composer/presentation/controller/rich_text_mobile_tablet_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

import 'composer_body_driver.dart';

ComposerBodyDriver createComposerBodyDriver() =>
    const ComposerBodyDriverMobile();

/// Drives the HTML editor WebView of the mobile/tablet composer.
class ComposerBodyDriverMobile implements ComposerBodyDriver {
  const ComposerBodyDriverMobile();

  @override
  Future<ComposerBodyResult> setBody(String text) async {
    final result = await _evaluate(_setBodyScript(text));
    if (result == null) return const ComposerNotFound();
    return ComposerBodyFound({'body': result.toString()});
  }

  @override
  Future<ComposerBodyResult> getBody() async {
    final result = await _evaluate(_getBodyScript);
    if (result == null) return const ComposerNotFound();
    return ComposerBodyFound(
      jsonDecode(result.toString()) as Map<String, dynamic>,
    );
  }

  Future<dynamic> _evaluate(String source) async {
    final editorApi =
        getBinding<RichTextMobileTabletController>()?.htmlEditorApi;
    if (editorApi == null) return null;
    return editorApi.webViewController.evaluateJavascript(source: source);
  }
}

String _setBodyScript(String text) =>
    '''
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
