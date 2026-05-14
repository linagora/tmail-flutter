import 'dart:convert';

import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../resources/test_images.dart';
import '../../robots/abstract/abstract_composer_robot.dart';
import '../../utils/wait_for_condition.dart';

abstract class BaseSaveDraftThenReopenScenario extends BaseTestScenario {
  const BaseSaveDraftThenReopenScenario(super.$, super.robots);

  String get subject;

  Future<void> attachContent(AbstractComposerRobot composerRobot, Uint8List bytes);

  Future<void> waitForContentUploaded(AbstractComposerRobot composerRobot);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    assert(email.isNotEmpty, 'BASIC_AUTH_EMAIL must not be empty');

    final uniqueSubject = '$subject ${DateTime.now().microsecondsSinceEpoch}';
    final threadRobot = robots.threadRobot();
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final composerRobot = robots.composerRobot();
    final appLocalizations = AppLocalizations();

    await threadRobot.openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    await composerRobot.addRecipient(PrefixEmailAddress.to, email);
    await composerRobot.addSubject(uniqueSubject);

    final bytes = base64Decode(TestImages.base64);
    await attachContent(composerRobot, bytes);
    await waitForContentUploaded(composerRobot);

    await composerRobot.tapCloseComposer();
    await $.pumpAndTrySettle();
    await expectViewVisible($(#confirm_dialog_action));
    await composerRobot.tapSaveButtonOnSaveDraftConfirmDialog(appLocalizations);
    await _expectSaveDraftSuccessToast(appLocalizations);
    await $.pumpAndTrySettle();

    if (PlatformInfo.isMobile) {
      await threadRobot.openMailbox();
    }
    await mailboxMenuRobot.openFolderByName(appLocalizations.draftsMailboxDisplayName);
    await waitForCondition(() => $(uniqueSubject).exists);
    await threadRobot.openEmailWithSubject(uniqueSubject);
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    await composerRobot.addSubject(' edited');

    await composerRobot.tapSaveAsDraftButton();
    await _expectSaveDraftSuccessToast(appLocalizations);

    await composerRobot.addSubject(' again');

    // This second save was the failing scenario before the fix
    await composerRobot.tapSaveAsDraftButton();
    await _expectSaveDraftSuccessToast(appLocalizations);
  }

  Future<void> _expectSaveDraftSuccessToast(AppLocalizations appLocalizations) async {
    await expectViewVisible($(find.text(appLocalizations.drafts_saved)));
  }
}
