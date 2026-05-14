import 'dart:convert';

import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/domain/state/get_email_content_state.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../resources/test_images.dart';
import '../../robots/abstract/abstract_composer_robot.dart';
import '../../utils/wait_for_condition.dart';

abstract class BaseSaveTemplateThenReopenScenario extends BaseTestScenario {
  const BaseSaveTemplateThenReopenScenario(super.$, super.robots);

  String get subject;

  Future<void> attachContent(AbstractComposerRobot composerRobot, Uint8List bytes);

  Future<void> waitForContentUploaded(AbstractComposerRobot composerRobot);

  @override
  Future<void> runTestLogic() async {
    final uniqueSubject = '$subject ${DateTime.now().microsecondsSinceEpoch}';
    final threadRobot = robots.threadRobot();
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final composerRobot = robots.composerRobot();
    final appLocalizations = AppLocalizations();

    if (PlatformInfo.isMobile) {
      await threadRobot.openMailbox();
    }
    await mailboxMenuRobot.openFolderByName(appLocalizations.templatesMailboxDisplayName);

    await threadRobot.openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    await composerRobot.addSubject(uniqueSubject);

    final bytes = base64Decode(TestImages.base64);
    await attachContent(composerRobot, bytes);
    await waitForContentUploaded(composerRobot);

    await composerRobot.tapSaveAsTemplateButton();
    await _expectSaveTemplateSuccessToast(appLocalizations);
    await $.pumpAndTrySettle();

    await composerRobot.tapCloseComposer();
    await $.pumpAndTrySettle();
    await composerRobot.tapDiscardChanges();
    await $.pumpAndTrySettle();

    await waitForCondition(() => $(uniqueSubject).exists);
    await threadRobot.openEmailWithSubject(uniqueSubject);
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    // Wait for the editor content (including inline images) to finish loading
    // before opening the popup menu. Without this wait, an onFocus event fired
    // by the editor when it receives new content can close the popup mid-open.
    await waitForCondition(() {
      final controller = composerRobot.findComposerController();
      if (controller == null) return false;
      final state = controller.emailContentsViewState.value;
      return state != null && state.fold(
        (_) => true,
        (s) => s is! GetEmailContentLoading,
      );
    });
    await $.pumpAndTrySettle();

    await composerRobot.addSubject(' edited');

    // Second save — should succeed after Email/get blob refresh
    await composerRobot.tapSaveAsTemplateButton();
    await _expectUpdateTemplateSuccessToast(appLocalizations);

    await composerRobot.addSubject(' again');

    // Third save — was the failing scenario before the fix
    await composerRobot.tapSaveAsTemplateButton();
    await _expectUpdateTemplateSuccessToast(appLocalizations);
  }

  Future<void> _expectSaveTemplateSuccessToast(AppLocalizations appLocalizations) async {
    await expectViewVisible($(find.text(appLocalizations.saveMessageToTemplateSuccess)));
  }

  Future<void> _expectUpdateTemplateSuccessToast(AppLocalizations appLocalizations) async {
    await expectViewVisible($(find.text(appLocalizations.updateMessageToTemplateSuccess)));
  }
}
