import 'package:flutter/foundation.dart' show TargetPlatform, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/web_editor_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../mobile/mobile_composer_robot.dart';

/// Web-specific composer robot. Overrides [addContent] because InAppWebView
/// is unavailable on web — content is injected via Patrol's web automator.
class WebComposerRobot extends MobileComposerRobot {
  WebComposerRobot(PatrolIntegrationTester $) : super($);

  @override
  Future<void> expectComposerViewVisible() async {
    await $.waitUntilVisible($(ComposerView));
  }

  @override
  Future<void> grantContactPermission() async {}

  @override
  Future<void> addContent(String content) async {
    await $(WebEditorWidget).tap();
    await $.platformAutomator.web.enterText(
      WebSelector(cssOrXpath: 'div.note-editable'),
      iframeSelector: WebSelector(cssOrXpath: 'iframe'),
      text: content,
    );
  }

  @override
  Future<void> tapSaveAsDraftButton() async {
    await $(const Key(UiKeys.saveDraftButton)).tap();
    await $.pumpAndSettle();
  }

  /// Resolves the [ComposerController] from the web [ComposerView] widget in
  /// the tree. On web, the controller is registered in GetX with a per-instance
  /// composerId tag, so [Get.find] without a tag fails. Reading it from the
  /// widget's [controller] getter is the only reliable approach.
  @override
  ComposerController? findComposerController() {
    final widgets = $.tester
        .widgetList<ComposerView>(find.byType(ComposerView))
        .toList();
    if (widgets.isEmpty) return null;
    return widgets.first.controller;
  }

  @override
  Future<void> tapSaveAsTemplateButton() async {
    await $(const Key(UiKeys.composerMoreButton)).tap();
    await $.pumpAndSettle();
    await $(const Key(UiKeys.saveTemplatePopupItem)).tap();
    await $.pumpAndSettle();
  }

  @override
  Future<void> openInsertLinkDialogViaKeyboardShortcut() async {
    await $(WebEditorWidget).tap();
    // enterText focuses div.note-editable inside the iframe and the element
    // retains focus afterward, so pressKeyCombo lands in Summernote rather
    // than the outer Flutter shell.
    await $.platformAutomator.web.enterText(
      WebSelector(cssOrXpath: 'div.note-editable'),
      iframeSelector: WebSelector(cssOrXpath: 'iframe'),
      text: ' ',
    );
    final isMac = defaultTargetPlatform == TargetPlatform.macOS;
    await $.platformAutomator.web.pressKeyCombo(
      keys: isMac ? ['Meta', 'k'] : ['Control', 'k'],
    );
    await $.pumpAndTrySettle();
  }

  // "Apply" is unique to the custom overlay; Summernote's native dialog never
  // renders this Flutter widget, so its presence confirms the correct dialog.
  @override
  Future<void> expectInsertLinkDialogVisible(AppLocalizations appLocalizations) async {
    await $.waitUntilVisible($(find.text(appLocalizations.apply)));
  }
}
