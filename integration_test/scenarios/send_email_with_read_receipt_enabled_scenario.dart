import 'package:core/presentation/resources/image_paths.dart';
import 'package:duration/duration.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/composer_robot.dart';
import '../robots/email_robot.dart';
import '../robots/thread_robot.dart';

class SendEmailWithReadReceiptEnabledScenario extends BaseTestScenario {
  const SendEmailWithReadReceiptEnabledScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');
    const emailSubject = 'Email with read receipt enabled';

    final threadRobot = ThreadRobot($);
    final composerRobot = ComposerRobot($);
    final emailRobot = EmailRobot($);
    final imagePaths = ImagePaths();
    final appLocalizations = AppLocalizations();

    await threadRobot.openComposer();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    await composerRobot.addRecipientIntoField(
      prefixEmailAddress: PrefixEmailAddress.to,
      email: emailUser,
    );

    await composerRobot.addSubject(emailSubject);
    await composerRobot.addContent(emailSubject);

    await composerRobot.tapMoreOptionOnAppBar();
    await $.pump(const Duration(seconds: 2));
    await _expectMoreOptionPopupMenuVisible();

    await composerRobot.tapReadReceiptPopupItemOnMenu();
    await $.pump(const Duration(seconds: 2));
    await _expectToastDisplayWithMessageReadReceiptEnabled(appLocalizations);

    await composerRobot.sendEmail(imagePaths);
    await $.pumpAndSettle(duration: seconds(5));
    await _expectEmailWithReadReceiptVisible(emailSubject);

    await threadRobot.openEmailWithSubject(emailSubject);
    await _expectReadReceiptRequestDialog(appLocalizations);

    await $.native.pressBack();
    await emailRobot.onTapBackButton();

    await $.pumpAndSettle(duration: seconds(5));

    // Try opening it again when the email is cached
    await threadRobot.openEmailWithSubject(emailSubject);
    await _expectReadReceiptRequestDialog(appLocalizations);
  }

  Future<void> _expectComposerViewVisible() => expectViewVisible($(ComposerView));

  Future<void> _expectMoreOptionPopupMenuVisible() async {
    await expectViewVisible($(#read_receipt_popup_item));
  }

  Future<void> _expectToastDisplayWithMessageReadReceiptEnabled(
    AppLocalizations appLocalizations,
  ) async {
    await expectViewVisible(
      $(find.text(appLocalizations.requestReadReceiptHasBeenEnabled)),
    );
  }

  Future<void> _expectReadReceiptRequestDialog(
    AppLocalizations appLocalizations
  ) async {
    await expectViewVisible(
      $(appLocalizations.titleReadReceiptRequestNotificationMessage)
    );
  }

  Future<void> _expectEmailWithReadReceiptVisible(String subject) async {
    await expectViewVisible($(EmailTileBuilder).$(find.text(subject)));
  }
}