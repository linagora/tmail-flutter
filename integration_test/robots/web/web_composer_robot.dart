import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/base/model/ui_keys.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view_web.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/web_editor_widget.dart';

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
}
