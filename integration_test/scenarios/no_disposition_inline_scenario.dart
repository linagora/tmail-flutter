import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/email/presentation/email_view.dart';
import 'package:tmail_ui_user/features/search/email/presentation/search_email_view.dart';

import '../base/base_test_scenario.dart';
import '../robots/search_robot.dart';
import '../robots/thread_robot.dart';

class NoDispositionInlineScenario extends BaseTestScenario {
  static const _firstPartOfBase64DataString = 'data:image/jpeg;base64';
  static const emailSubject = 'Greeting Card';

  const NoDispositionInlineScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final searchRobot = SearchRobot($);
    
    await threadRobot.openSearchView();
    await _expectSearchViewVisible();

    await searchRobot.enterQueryString(emailSubject);
    await searchRobot.tapOnShowAllResultsText();
    await _expectSearchResultEmailListVisible();

    await searchRobot.openEmailWithSubject(emailSubject);
    await _expectEmailViewVisible();
    await _expectHtmlContentViewerVisible();
    await _expectEmailViewWithBase64Image();
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

  Future<void> _expectHtmlContentViewerVisible() async {
    await expectViewVisible($(HtmlContentViewer));
  }

  Future<void> _expectEmailViewWithBase64Image() async {
    expect(
      $(EmailView)
        .$(HtmlContentViewer)
        .which<HtmlContentViewer>((view) {
          return view.contentHtml.contains(_firstPartOfBase64DataString);
        }),
      findsOneWidget,
    );
  }
}