import 'dart:convert';

import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
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

    await composerRobot.addSubject(subject);

    final bytes = base64Decode(TestImages.base64);
    await attachContent(composerRobot, bytes);
    await waitForContentUploaded(composerRobot);

    await composerRobot.saveAsTemplate();
    await _expectSaveTemplateSuccessToast(appLocalizations);
    await $.pumpAndSettle();

    await composerRobot.tapCloseComposer();
    await $.pumpAndSettle();
    await composerRobot.tapDiscardChanges();
    await $.pumpAndSettle();

    await waitForCondition(() => $(find.text(subject)).exists);
    await threadRobot.openEmailWithSubject(subject);
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    await composerRobot.addSubject(' edited');

    // Second save — should succeed after Email/get blob refresh
    await composerRobot.saveAsTemplate();
    await _expectUpdateTemplateSuccessToast(appLocalizations);

    await composerRobot.addSubject(' again');

    // Third save — was the failing scenario before the fix
    await composerRobot.saveAsTemplate();
    await _expectUpdateTemplateSuccessToast(appLocalizations);
  }

  Future<void> _expectSaveTemplateSuccessToast(AppLocalizations appLocalizations) async {
    await expectViewVisible($(find.text(appLocalizations.saveMessageToTemplateSuccess)));
  }

  Future<void> _expectUpdateTemplateSuccessToast(AppLocalizations appLocalizations) async {
    await expectViewVisible($(find.text(appLocalizations.updateMessageToTemplateSuccess)));
  }
}
