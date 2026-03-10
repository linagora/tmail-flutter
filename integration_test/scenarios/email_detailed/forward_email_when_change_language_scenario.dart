import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/generate_email_scenario_mixin.dart';
import '../../mixin/screen_scenario_mixin.dart';
import '../../mixin/setting_scenario_mixin.dart';
import '../../robots/composer_robot.dart';
import '../../robots/email_robot.dart';
import '../../robots/language_robot.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/setting_robot.dart';
import '../../robots/thread_robot.dart';

class ForwardEmailWhenChangeLanguageScenario extends BaseTestScenario
    with SettingScenarioMixin, GenerateEmailScenarioMixin, ScreenScenarioMixin {
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

      await goToSettingToChangeLanguage(
        threadRobot: threadRobot,
        settingRobot: settingRobot,
        mailboxMenuRobot: mailboxMenuRobot,
        languageRobot: languageRobot,
        appLocalizations: appLocalizations,
        locale: locale,
      );

      await generateEmailWithSubject(emailUser: emailUser, subject: subject);

      await _forwardEmailBySubject(
        threadRobot: threadRobot,
        emailRobot: emailRobot,
        composerRobot: composerRobot,
        subject: subject,
        appLocalizations: appLocalizations,
      );

      await closeComposer(
        composerRobot: composerRobot,
        imagePaths: imagePaths,
      );

      await closeEmailDetailedView(emailRobot: emailRobot);

      await $.pumpAndTrySettle();
    }
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
