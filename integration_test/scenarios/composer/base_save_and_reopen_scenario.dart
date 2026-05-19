import 'dart:convert';

import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../resources/test_images.dart';
import '../../robots/abstract/abstract_composer_robot.dart';
import '../../utils/wait_for_condition.dart';

abstract class BaseSaveAndReopenScenario extends BaseTestScenario {
  const BaseSaveAndReopenScenario(super.$, super.robots);

  String get subject;

  Future<void> attachContent(AbstractComposerRobot composerRobot, Uint8List bytes);

  Future<void> waitForContentUploaded(AbstractComposerRobot composerRobot);

  String folderDisplayName(AppLocalizations l10n);

  Future<void> performFirstSave(
    AbstractComposerRobot composerRobot,
    AppLocalizations l10n,
  );

  Future<void> performSubsequentSave(
    AbstractComposerRobot composerRobot,
    AppLocalizations l10n,
  );

  Future<void> onPreComposerSetup() async {}

  Future<void> onAfterContentUploaded() async {}

  Future<void> onAfterComposerReopened() async {}

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    assert(email.isNotEmpty, 'BASIC_AUTH_EMAIL must not be empty');

    final uniqueSubject = '$subject ${DateTime.now().microsecondsSinceEpoch}';
    final threadRobot = robots.threadRobot();
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final composerRobot = robots.composerRobot();
    final appLocalizations = AppLocalizations();

    await onPreComposerSetup();

    await timedStep('open_composer', () => threadRobot.openComposer());
    await timedStep('expect_composer', () => composerRobot.expectComposerViewVisible());
    await timedStep('grant_contact_permission', () => composerRobot.grantContactPermission());

    await timedStep('add_recipient', () => composerRobot.addRecipient(PrefixEmailAddress.to, email));
    await timedStep('add_subject', () => composerRobot.addSubject(uniqueSubject));

    final bytes = base64Decode(TestImages.base64);
    await timedStep('attach_content', () async {
      await attachContent(composerRobot, bytes);
      await waitForContentUploaded(composerRobot);
      await onAfterContentUploaded();
    });

    await timedStep('first_save', () => performFirstSave(composerRobot, appLocalizations));

    await timedStep('navigate_to_folder', () async {
      if (PlatformInfo.isMobile) {
        await threadRobot.openMailbox();
      }
      await mailboxMenuRobot.openFolderByName(folderDisplayName(appLocalizations));
      await waitForCondition(() => $(uniqueSubject).exists);
    });

    await timedStep('reopen_email', () async {
      await threadRobot.openEmailWithSubject(uniqueSubject);
      await composerRobot.expectComposerViewVisible();
      await composerRobot.grantContactPermission();
      await onAfterComposerReopened();
    });

    await timedStep('second_save', () async {
      await composerRobot.addSubject(' edited');
      await performSubsequentSave(composerRobot, appLocalizations);
    });

    await timedStep('third_save', () async {
      await composerRobot.addSubject(' again');
      await performSubsequentSave(composerRobot, appLocalizations);
    });
  }
}
