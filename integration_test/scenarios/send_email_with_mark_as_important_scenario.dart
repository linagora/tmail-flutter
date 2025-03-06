import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/composer_robot.dart';
import '../robots/thread_robot.dart';

class SendEmailWithMarkAsImportantScenario extends BaseTestScenario {
  const SendEmailWithMarkAsImportantScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const emailContent = 'Mark email as important';

    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);
    final imagePaths = ImagePaths();
    final appLocalizations = AppLocalizations();

    await threadRobot.openComposer();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    await composerRobot.addRecipientIntoField(
      prefixEmailAddress: PrefixEmailAddress.to,
      email: emailUser,
    );
    await composerRobot.addSubject(emailContent);
    await composerRobot.addContent(emailContent);

    await composerRobot.tapMoreOptionOnAppBar();
    await $.pump(const Duration(seconds: 2));
    await _expectMoreOptionPopupMenuVisible();

    await composerRobot.tapMarkAsImportantPopupItemOnMenu();
    await $.pump(const Duration(seconds: 2));
    await _expectToastDisplayWithMessageMarkAsImportantIsEnabled(appLocalizations);

    await composerRobot.sendEmail(imagePaths);
    await _expectSendEmailSuccessToast(appLocalizations);
    await $.pump(const Duration(seconds: 2));

    await _expectDisplayedEmailHasImportantFlagIcon();
  }
  
  Future<void> _expectComposerViewVisible() => expectViewVisible($(ComposerView));

  Future<void> _expectMoreOptionPopupMenuVisible() async {
    await expectViewVisible($(#mark_as_important_popup_item));
  }

  Future<void> _expectToastDisplayWithMessageMarkAsImportantIsEnabled(
    AppLocalizations appLocalizations,
  ) async {
    await expectViewVisible(
      $(find.text(appLocalizations.markAsImportantIsEnabled)),
    );
  }

  Future<void> _expectSendEmailSuccessToast(
    AppLocalizations appLocalizations,
  ) async {
    await expectViewVisible(
      $(find.text(appLocalizations.message_has_been_sent_successfully)),
    );
  }

  Future<void> _expectDisplayedEmailHasImportantFlagIcon() async {
    await expectViewVisible(
      $(EmailTileBuilder)
        .which<EmailTileBuilder>(
          (widget) => widget.presentationEmail.isMarkAsImportant
            && widget.isSenderImportantFlagEnabled
        ),
    );
    await expectViewVisible($(#important_flag_icon));
  }
}