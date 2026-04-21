import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/utils/email_utils.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../mixin/open_calendar_event_scenario_mixin.dart';
import '../../robots/composer_robot.dart';
import '../../robots/email_robot.dart';
import '../../robots/search_robot.dart';
import '../../robots/thread_robot.dart';

class MailToAttendeesEventEmailScenario extends BaseTestScenario
    with OpenCalendarEventScenarioMixin {
  const MailToAttendeesEventEmailScenario(super.$, super.robots);

  static const _expectedEventTitle = 'Come for a chat';

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final searchRobot = SearchRobot($);
    final composerRobot = ComposerRobot($);
    final emailRobot = EmailRobot($);
    final appLocalizations = AppLocalizations();

    await openCalendarEvent(
      threadRobot: threadRobot,
      searchRobot: searchRobot,
      appLocalizations: appLocalizations,
    );

    await emailRobot.tapMailToAttendeesEventActionButton();
    await _expectComposerViewVisible();
    await composerRobot.grantContactPermission();

    await _expectSubjectFilledCorrectly(appLocalizations);
  }

  Future<void> _expectComposerViewVisible() async {
    await expectViewVisible($(ComposerView));
  }

  Future<void> _expectSubjectFilledCorrectly(
    AppLocalizations appLocalizations,
  ) async {
    await expectViewVisible($(SubjectComposerWidget));

    final composerController = Get.find<ComposerController>();
    final actualSubject = composerController.subjectEmail.value ?? '';

    final expectedSubject = EmailUtils.applyPrefix(
      subject: _expectedEventTitle,
      defaultPrefix: EmailUtils.defaultReplyPrefix,
      localizedPrefix: appLocalizations.prefix_reply_email,
    );

    expect(actualSubject, contains(appLocalizations.prefix_reply_email));
    expect(actualSubject, equals(expectedSubject));
  }
}
