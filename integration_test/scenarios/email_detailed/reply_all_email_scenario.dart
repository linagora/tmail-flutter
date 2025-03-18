
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/recipient_composer_widget.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/subject_composer_widget.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/composer_robot.dart';
import '../../robots/email_robot.dart';
import '../../robots/search_robot.dart';
import '../../robots/thread_robot.dart';

class ReplyAllEmailScenario extends BaseTestScenario {

  const ReplyAllEmailScenario(super.$);

  static const String queryString = 'Reply all email';

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final searchRobot = SearchRobot($);
    final emailRobot = EmailRobot($);
    final composerRobot = ComposerRobot($);
    final appLocalizations = AppLocalizations();

    await threadRobot.openSearchView();
    await _expectSearchViewVisible();

    await searchRobot.enterQueryString(queryString);
    await searchRobot.tapOnShowAllResultsText();
    await _expectSearchResultEmailListVisible();

    await searchRobot.openEmailWithSubject(queryString);
    await _expectEmailViewVisible();
    await _expectReplyAllEmailButtonVisible();

    await emailRobot.onTapReplyAllEmail();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    await _expectComposerSubjectDisplayedCorrectly(appLocalizations);
    await _expectToFieldContainListEmailAddressCorrectly();
    await _expectCcFieldContainListEmailAddressCorrectly();
    await _expectBccFieldContainListEmailAddressCorrectly();
  }

  Future<void> _expectSearchViewVisible() async {
    await expectViewVisible($(SearchEmailView));
  }

  Future<void> _expectSearchResultEmailListVisible() async {
    await expectViewVisible($(#search_email_list_notification_listener));
    await $.pump(const Duration(seconds: 3));
  }

  Future<void> _expectEmailViewVisible() async {
    await expectViewVisible($(EmailView));
  }

  Future<void> _expectReplyAllEmailButtonVisible() async {
    await expectViewVisible($(#reply_all_emails_button));
  }

  Future<void> _expectComposerViewVisible() async {
    await expectViewVisible($(ComposerView));
  }

  Future<void> _expectComposerSubjectDisplayedCorrectly(AppLocalizations appLocalizations) async {
    expect(
      $(SubjectComposerWidget).which<SubjectComposerWidget>((widget) =>
        widget.textController.text == '${appLocalizations.prefix_reply_email} $queryString'
      ).visible,
      isTrue,
    );
  }

  Future<void> _expectToFieldContainListEmailAddressCorrectly() async {
    expect(
      $(RecipientComposerWidget).which<RecipientComposerWidget>((widget) =>
        widget.prefix == PrefixEmailAddress.to &&
        isMatchingEmailList(widget.listEmailAddress, {'emma@example.com'})
      ).visible,
      isTrue,
    );
  }

  Future<void> _expectCcFieldContainListEmailAddressCorrectly() async {
    expect(
      $(RecipientComposerWidget).which<RecipientComposerWidget>((widget) =>
        widget.prefix == PrefixEmailAddress.cc &&
        isMatchingEmailList(widget.listEmailAddress, {'alice@example.com'})
      ).visible,
      isTrue,
    );
  }

  Future<void> _expectBccFieldContainListEmailAddressCorrectly() async {
    expect(
      $(RecipientComposerWidget).which<RecipientComposerWidget>((widget) =>
        widget.prefix == PrefixEmailAddress.bcc &&
        isMatchingEmailList(widget.listEmailAddress, {'brian@example.com'})
      ).visible,
      isTrue,
    );
  }
}