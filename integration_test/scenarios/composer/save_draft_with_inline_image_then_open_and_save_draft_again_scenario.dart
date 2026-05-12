import 'dart:convert';

import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../resources/test_images.dart';
import '../../robots/abstract/abstract_composer_robot.dart';
import '../../utils/wait_for_condition.dart';

class SaveDraftWithInlineImageThenOpenAndSaveDraftAgainScenario extends BaseTestScenario {

  const SaveDraftWithInlineImageThenOpenAndSaveDraftAgainScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'Draft with inline image - second save';

    final threadRobot = robots.threadRobot();
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final composerRobot = robots.composerRobot();
    final appLocalizations = AppLocalizations();

    // Setup: Compose a new email with an inline image and save as draft
    await threadRobot.openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    await composerRobot.addRecipient(PrefixEmailAddress.to, email);
    await composerRobot.addSubject(subject);

    final bytes = base64Decode(TestImages.base64);
    await composerRobot.addInlineFromBytes(bytes, 'draft-inline.png');
    await _waitForInlineImageUploaded(composerRobot);

    await composerRobot.tapCloseComposer();
    await $.pumpAndSettle();
    await _expectSaveDraftConfirmDialogVisible();
    await composerRobot.tapSaveButtonOnSaveDraftConfirmDialog(appLocalizations);
    await _expectSaveDraftSuccessToast(appLocalizations);
    await $.pumpAndSettle();

    // Step 1: Open the existing draft from the Drafts folder
    if (PlatformInfo.isMobile) {
      await threadRobot.openMailbox();
    }
    await mailboxMenuRobot.openFolderByName(appLocalizations.draftsMailboxDisplayName);
    await $.pump(const Duration(seconds: 2));
    await threadRobot.openEmailWithSubject(subject);
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    // Step 2: Edit the subject
    await composerRobot.addSubject(' edited');

    // Step 3: Save as Draft for the first time (keep composer open)
    await composerRobot.tapSaveAsDraftButton();
    await _expectSaveDraftSuccessToast(appLocalizations);

    // Step 4: Continue editing the subject
    await composerRobot.addSubject(' again');

    // Step 5: Save as Draft a second time — this was the failing scenario before the fix
    await composerRobot.tapSaveAsDraftButton();
    await _expectSaveDraftSuccessToast(appLocalizations);
  }

  Future<void> _waitForInlineImageUploaded(AbstractComposerRobot composerRobot) => waitForCondition(() {
    final controller = composerRobot.findComposerController();
    return controller?.uploadController.inlineAttachmentsUploaded.isNotEmpty ?? false;
  });

  Future<void> _expectSaveDraftConfirmDialogVisible() async {
    await expectViewVisible($(#confirm_dialog_action));
  }

  Future<void> _expectSaveDraftSuccessToast(AppLocalizations appLocalizations) async {
    await expectViewVisible($(find.text(appLocalizations.drafts_saved)));
  }
}
