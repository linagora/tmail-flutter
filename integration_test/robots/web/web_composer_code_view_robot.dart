import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:web/web.dart' as web;

import '../../base/core_robot.dart';
import '../../utils/wait_for_condition.dart';
import '../abstract/abstract_composer_code_view_robot.dart';
import 'web_composer_controller_finder.dart';

class WebComposerCodeViewRobot extends CoreRobot
    implements AbstractComposerCodeViewRobot {
  WebComposerCodeViewRobot(PatrolIntegrationTester $) : super($);

  static const _markerAttribute = 'data-tmail-code-view-xss';

  // The editor iframe is same-origin, so `window.top` reaches the app page.
  static const _payload =
      '<img src="x" onerror="window.top.document.documentElement'
      '.setAttribute(\'$_markerAttribute\', \'ran\')">'
      '<p>visible text</p>';

  static const _scriptOnlyPayload =
      '<script>window.top.document.documentElement'
      '.setAttribute(\'$_markerAttribute\', \'ran\')</script>';

  static const _activeContentSelector = 'script, [onerror], [onload]';

  // Long enough for the broken image's error event to fire.
  static const _scriptGracePeriod = Duration(seconds: 2);

  @override
  Future<void> openEmbedCode() => _toggleEmbedCode(expectCodeViewEnabled: true);

  @override
  Future<void> leaveEmbedCode() =>
      _toggleEmbedCode(expectCodeViewEnabled: false);

  Future<void> _toggleEmbedCode({required bool expectCodeViewEnabled}) async {
    await $(const Key(UiKeys.composerMoreButton)).tap();
    await $.pumpAndSettle();
    await $(find.text(AppLocalizations().embedCode)).tap();
    await $.pumpAndSettle();
    await waitForCondition(
      () =>
          findWebComposerController($)?.richTextWebController?.codeViewEnabled ==
          expectCodeViewEnabled,
    );
  }

  @override
  Future<void> typeActiveContentPayload() => _typeInCodeView(_payload);

  @override
  Future<void> typeScriptOnlyPayload() => _typeInCodeView(_scriptOnlyPayload);

  Future<void> _typeInCodeView(String payload) async {
    web.document.documentElement?.removeAttribute(_markerAttribute);
    await $.platformAutomator.web.enterText(
      WebSelector(cssOrXpath: 'textarea.note-codable'),
      iframeSelector: WebSelector(cssOrXpath: 'iframe'),
      text: payload,
    );
    // Guards against a vacuous pass: the payload must sit in the code view.
    await waitForCondition(
      () => _codeViewText()?.contains(_markerAttribute) == true,
    );
  }

  @override
  Future<void> pressEscape() async {
    await $.platformAutomator.web.pressKey(key: 'Escape');
    await $.pumpAndTrySettle();
  }

  @override
  Future<void> expectActiveContentDidNotRun() async {
    await Future.delayed(_scriptGracePeriod);
    await $.pumpAndTrySettle();
    expect(
      web.document.documentElement?.getAttribute(_markerAttribute),
      isNull,
      reason: 'HTML typed in the code view ran its event handler',
    );
    // A browser can refuse to run the handler, so also check the editable
    // itself: active markup must never reach it, whatever the exit path.
    expect(
      _editorDocument()
          ?.querySelector('div.note-editable')
          ?.querySelector(_activeContentSelector),
      isNull,
      reason: 'active markup from the code view reached the editor',
    );
  }

  String? _codeViewText() {
    final textarea = _editorDocument()?.querySelector('textarea.note-codable');
    return (textarea as web.HTMLTextAreaElement?)?.value;
  }

  web.Document? _editorDocument() {
    final iframes = web.document.querySelectorAll('iframe');
    for (var i = 0; i < iframes.length; i++) {
      final iframe = iframes.item(i) as web.HTMLIFrameElement;
      final document = iframe.contentDocument;
      if (document?.querySelector('textarea.note-codable') != null) {
        return document;
      }
    }
    return null;
  }
}
