import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/label_mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/composer_robot.dart';
import '../robots/mailbox_menu_robot.dart';
import '../robots/thread_robot.dart';

class SaveDraftThenCloseComposerAndOpenDraftScenario extends BaseTestScenario {

  const SaveDraftThenCloseComposerAndOpenDraftScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const subject = 'Save draft email without Reply-To';

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

    await composerRobot.tapCloseComposer(imagePaths);
    await $.pump(const Duration(seconds: 2));
    await _expectSaveDraftConfirmDialogVisible();

    await composerRobot.tapSaveButtonOnSaveDraftConfirmDialog(appLocalizations);
    await _expectSaveDraftEmailSuccessToast(appLocalizations);

    await $.pump(const Duration(seconds: 2));

    await threadRobot.openMailbox();
    await _expectMailboxViewVisible();
    await _expectDraftFolderVisible(appLocalizations);

    await mailboxMenuRobot.openFolderByName(appLocalizations.draftsMailboxDisplayName);
    await $.pump(const Duration(seconds: 2));
    await _expectDraftEmailWithSubjectVisible(subject);

    await threadRobot.openEmailWithSubject(subject);
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();
    await _expectMobileEditorViewVisible();

    await _expectReplyToFiledInvisible();
  }
  
  Future<void> _expectComposerViewVisible() => expectViewVisible($(ComposerView));

  Future<void> _expectSaveDraftEmailSuccessToast(AppLocalizations appLocalizations) async {
    await expectViewVisible($(find.text(appLocalizations.drafts_saved)));
  }

  Future<void> _expectSaveDraftConfirmDialogVisible() async {
    await expectViewVisible($(#confirm_dialog_action));
  }

  Future<void> _expectMailboxViewVisible() => expectViewVisible($(MailboxView));

  Future<void> _expectDraftFolderVisible(AppLocalizations appLocalizations) =>
    expectViewVisible(
      $(MailboxItemWidget)
        .$(LabelMailboxItemWidget)
        .$(find.text(appLocalizations.draftsMailboxDisplayName))
    );

  Future<void> _expectDraftEmailWithSubjectVisible(String subject) async {
    await expectViewVisible($(EmailTileBuilder).$(find.text(subject)));
  }

  Future<void> _expectMobileEditorViewVisible() async {
    await expectViewVisible($(#mobile_editor));
  }

  Future<void> _expectReplyToFiledInvisible() async {
    expect(
      $(RecipientComposerWidget)
        .which<RecipientComposerWidget>((view) => view.prefix == PrefixEmailAddress.replyTo),
      findsNothing,
    );
  }
}