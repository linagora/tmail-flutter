
import 'package:flutter_test/flutter_test.dart';
import 'package:rich_text_composer/rich_text_composer.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/composer/presentation/view/mobile/mobile_editor_view.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';

import '../base/base_test_scenario.dart';
import '../robots/composer_robot.dart';
import '../robots/email_robot.dart';
import '../robots/search_robot.dart';
import '../robots/thread_robot.dart';

class ForwardEmailScenario extends BaseTestScenario {

  static const String queryString = 'Fwd: Forward email to Bob';

  const ForwardEmailScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    await threadRobot.openSearchView();
    await _expectSearchViewVisible();

    final searchRobot = SearchRobot($);
    await searchRobot.enterQueryString(queryString);
    await searchRobot.tapOnShowAllResultsText();
    await _expectSearchResultEmailListVisible();

    await searchRobot.openEmailWithSubject(queryString);
    await _expectEmailViewVisible();
    await _expectForwardEmailButtonVisible();

    final emailRobot = EmailRobot($);
    await emailRobot.onTapForwardEmail();
    await _expectComposerViewVisible();

    final composerRobot = ComposerRobot($);
    await composerRobot.grantContactPermission();
    await _expectMobileEditorViewVisible();

    await _expectForwardEmailContentDisplayedCorrectly();
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

  Future<void> _expectForwardEmailButtonVisible() async {
    await expectViewVisible($(#forward_email_button));
  }

  Future<void> _expectComposerViewVisible() async {
    await expectViewVisible($(ComposerView));
  }

  Future<void> _expectMobileEditorViewVisible() async {
    await expectViewVisible($(#mobile_editor));
  }

  Future<void> _expectForwardEmailContentDisplayedCorrectly() async {
    ComposerController? composerController;
    await $(ComposerView)
      .which<ComposerView>((widget) {
        composerController = widget.controller;
        return true;
      })
      .$(MobileEditorView)
      .$(HtmlEditor)
      .$(InAppWebView).tap();

    await composerController?.htmlEditorApi?.requestFocusLastChild();

    final contentHtml = await composerController?.htmlEditorApi?.getText();

    expect(contentHtml, contains('Subject'));
    expect(contentHtml, contains('From'));
    expect(contentHtml, contains('To'));
    expect(contentHtml, contains('Cc'));
    expect(contentHtml, contains('Bcc'));
  }
}