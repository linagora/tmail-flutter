import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/composer_robot.dart';
import '../../robots/email_robot.dart';
import '../../robots/language_robot.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/setting_robot.dart';
import '../../robots/thread_robot.dart';

class ForwardEmailWhenChangeLanguageScenario extends BaseTestScenario {
  const ForwardEmailWhenChangeLanguageScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);
    final composerRobot = ComposerRobot($);
    final settingRobot = SettingRobot($);
    final languageRobot = LanguageRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final imagePaths = ImagePaths();

    for (var locale in LocalizationService.supportedLocales) {
      String subject = 'Forward email by locale ${locale.languageCode}';

      final appLocalizations = await AppLocalizations.load(locale);

      await _goToSettingToChangeLanguage(
        threadRobot: threadRobot,
        settingRobot: settingRobot,
        mailboxMenuRobot: mailboxMenuRobot,
        languageRobot: languageRobot,
        appLocalizations: appLocalizations,
        locale: locale,
      );

      await _generateEmail(emailUser, subject);

      await _forwardEmailBySubject(
        threadRobot: threadRobot,
        emailRobot: emailRobot,
        composerRobot: composerRobot,
        subject: subject,
        appLocalizations: appLocalizations,
      );

      await _closeComposer(
        composerRobot: composerRobot,
        imagePaths: imagePaths,
      );

      await _closeEmailDetailedView(emailRobot: emailRobot);

      await $.pumpAndTrySettle();
    }
  }

  Future<void> _goToSettingToChangeLanguage({
    required ThreadRobot threadRobot,
    required SettingRobot settingRobot,
    required MailboxMenuRobot mailboxMenuRobot,
    required LanguageRobot languageRobot,
    required AppLocalizations appLocalizations,
    required Locale locale,
  }) async {
    await threadRobot.openMailbox();
    await mailboxMenuRobot.openSetting();
    await _expectLanguageMenuItemVisible();

    await settingRobot.openLanguageMenuItem();
    await languageRobot.openLanguageContextMenu();
    await languageRobot.selectLanguage(locale, appLocalizations);
    await _expectLanguageViewByLocaleTitleVisible(appLocalizations);

    await settingRobot.backToSettingsFromFirstLevel();
    await settingRobot.closeSettings();
  }

  Future<void> _generateEmail(String emailUser, String subject) async {
    await provisionEmail(
      [
        ProvisioningEmail(
          toEmail: emailUser,
          subject: subject,
          content: subject,
        ),
      ],
      requestReadReceipt: false,
    );
    await $.pumpAndTrySettle();
  }

  Future<void> _forwardEmailBySubject({
    required ThreadRobot threadRobot,
    required EmailRobot emailRobot,
    required ComposerRobot composerRobot,
    required String subject,
    required AppLocalizations appLocalizations,
  }) async {
    await threadRobot.openEmailWithSubject(subject);
    await _expectEmailViewVisible();
    await _expectForwardEmailButtonVisible();

    await emailRobot.onTapForwardEmail();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();
    await $.pumpAndTrySettle();

    await _expectComposerSubjectDisplayedCorrectly(
      appLocalizations: appLocalizations,
      subject: subject,
    );
  }

  Future<void> _closeComposer({
    required ComposerRobot composerRobot,
    required ImagePaths imagePaths,
  }) async {
    await composerRobot.tapCloseComposer(imagePaths);
    await composerRobot.tapDiscardChanges();
  }

  Future<void> _closeEmailDetailedView({required EmailRobot emailRobot}) async {
    await emailRobot.onTapBackButton();
  }

  Future<void> _expectLanguageMenuItemVisible() async {
    await $(#setting_language_region).scrollTo(
      scrollDirection: AxisDirection.down,
    );
    await expectViewVisible($(#setting_language_region));
  }

  Future<void> _expectLanguageViewByLocaleTitleVisible(
    AppLocalizations appLocalizations,
  ) async {
    await expectViewVisible($(find.text(appLocalizations.language)));
  }

  Future<void> _expectEmailViewVisible() async {
    await expectViewVisible($(EmailView));
  }

  Future<void> _expectForwardEmailButtonVisible() async {
    await expectViewVisible($(#forward_email_button));
  }

  Future<void> _expectComposerViewVisible() async {
    await expectViewVisible($(ComposerView));
  }

  Future<void> _expectComposerSubjectDisplayedCorrectly({
    required AppLocalizations appLocalizations,
    required String subject,
  }) async {
    expect(
      $(SubjectComposerWidget)
          .which<SubjectComposerWidget>((widget) =>
              widget.textController.text ==
              '${appLocalizations.prefix_forward_email} $subject')
          .visible,
      isTrue,
    );
  }
}
