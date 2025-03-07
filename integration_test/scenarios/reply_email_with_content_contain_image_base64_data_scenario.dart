import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/widgets/email_tile_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/base_test_scenario.dart';
import '../robots/composer_robot.dart';
import '../robots/email_robot.dart';
import '../robots/search_robot.dart';
import '../robots/thread_robot.dart';

class ReplyEmailWithContentContainImageBase64DataScenario extends BaseTestScenario {
  const ReplyEmailWithContentContainImageBase64DataScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    const emailSubject = 'Mail with base64';
    const emailUser = String.fromEnvironment('BASIC_AUTH_EMAIL');

    final threadRobot = ThreadRobot($);
    final searchRobot = SearchRobot($);
    final emailRobot = EmailRobot($);
    final composerRobot = ComposerRobot($);
    final imagePaths = ImagePaths();
    final appLocalizations = AppLocalizations();

    await threadRobot.openSearchView();
    await _expectSearchViewVisible();

    await searchRobot.enterQueryString(emailSubject);
    await searchRobot.tapOnShowAllResultsText();
    await _expectSearchResultEmailListVisible();

    await searchRobot.openEmailWithSubject(emailSubject);
    await _expectEmailViewVisible();
    await _expectReplyEmailButtonVisible();

    await emailRobot.onTapReplyEmail();
    await _expectComposerViewVisible();

    await composerRobot.grantContactPermission();

    await composerRobot.addRecipientIntoField(
      prefixEmailAddress: PrefixEmailAddress.to,
      email: emailUser,
    );

    await composerRobot.sendEmail(imagePaths);
    await _expectSendEmailSuccessToast(appLocalizations);
    await Future.delayed(const Duration(seconds: 3));

    await emailRobot.onTapBackButton();
    await $.pumpAndSettle(duration: const Duration(seconds: 3));
    await _expectEmailCidWithSubject(emailSubject);

    await threadRobot.openEmailWithSubject(
      '${appLocalizations.prefix_reply_email} $emailSubject'
    );
    await _expectEmailViewVisible();
    await Future.delayed(const Duration(seconds: 3));
    await _ensureHtmlContentViewerVisible();
    await _expectEmailViewWithCidImage();
  }

  Future<void> _expectSearchViewVisible() async {
    await expectViewVisible($(SearchEmailView));
  }

  Future<void> _expectSearchResultEmailListVisible() async {
    await expectViewVisible($(#search_email_list_notification_listener));
  }

  Future<void> _expectEmailViewVisible() async {
    await expectViewVisible($(EmailView));
  }

  Future<void> _expectReplyEmailButtonVisible() async {
    await expectViewVisible($(#reply_email_button));
  }

  Future<void> _expectComposerViewVisible() async {
    await expectViewVisible($(ComposerView));
  }

  Future<void> _expectSendEmailSuccessToast(AppLocalizations appLocalizations) async {
    await expectViewVisible(
      $(find.text(appLocalizations.message_has_been_sent_successfully)),
    );
  }

  Future<void> _expectEmailCidWithSubject(String subject) => expectViewVisible(
    $(EmailTileBuilder)
      .which<EmailTileBuilder>(
        (widget) => widget.presentationEmail.subject?.contains(subject) == true
      ),
  );

  Future<void> _ensureHtmlContentViewerVisible() async {
    await $(HtmlContentViewer).scrollTo(scrollDirection: AxisDirection.down);
  }

  Future<void> _expectEmailViewWithCidImage() async {
    HtmlContentViewer? htmlContentViewer;

    await $(HtmlContentViewer)
      .which<HtmlContentViewer>((view) {
        htmlContentViewer = view;
        return true;
      })
      .first
      .tap();

    final contentHtml = htmlContentViewer!.contentHtml;
    final cidCount = RegExp(r'cid').allMatches(contentHtml).length;
    expect(cidCount, 2);
  }
}