import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/composer_robot.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class UpdateDraftEmailWithMessageSuccessToastScenario extends BaseTestScenario {

  const UpdateDraftEmailWithMessageSuccessToastScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'Update draft email with message toast';
    const updatedSubject = 'New update draft email with message toast';

    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();
    final imagePaths = ImagePaths();

    await threadRobot.openComposer();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();
    await composerRobot.addRecipientIntoField(
      prefixEmailAddress: PrefixEmailAddress.to,
      email: email,
    );
    await composerRobot.addSubject(subject);
    await composerRobot.addContent(subject);

    await composerRobot.tapCloseComposer(imagePaths);
    await $.pumpAndSettle();
    await _expectSaveDraftConfirmDialogVisible();

    await composerRobot.tapSaveButtonOnSaveDraftConfirmDialog(appLocalizations);
    await _expectSaveDraftEmailSuccessToast(appLocalizations);
    await $.pumpAndSettle();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.openFolderByName(
      appLocalizations.draftsMailboxDisplayName,
    );
    await threadRobot.openEmailWithSubject(subject);
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();
    await composerRobot.addSubject(updatedSubject);
    await composerRobot.tapCloseComposer(imagePaths);
    await $.pumpAndSettle();
    await _expectSaveDraftConfirmDialogVisible();

    await composerRobot.tapSaveButtonOnSaveDraftConfirmDialog(appLocalizations);
    await _expectSaveDraftEmailSuccessToast(appLocalizations);
  }
  
  Future<void> _expectComposerViewVisible() => expectViewVisible($(ComposerView));

  Future<void> _expectSaveDraftEmailSuccessToast(AppLocalizations appLocalizations) async {
    await expectViewVisible($(find.text(appLocalizations.drafts_saved)));
  }

  Future<void> _expectSaveDraftConfirmDialogVisible() async {
    await expectViewVisible($(#confirm_dialog_action));
  }
}