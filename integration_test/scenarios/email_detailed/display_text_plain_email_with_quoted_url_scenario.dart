import 'package:core/presentation/views/html_viewer/html_content_viewer_on_web_widget.dart';
import 'package:core/presentation/views/html_viewer/html_content_viewer_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:tmail_ui_user/features/thread/presentation/thread_controller.dart';

import '../../base/base_test_scenario.dart';
import '../../utils/jmap/jmap_text_plain_email_provisioner.dart';
import '../../utils/wait_for_mailbox_ready.dart';

class DisplayTextPlainEmailWithQuotedUrlScenario extends BaseTestScenario {
  const DisplayTextPlainEmailWithQuotedUrlScenario(super.$, super.robots);

  static const String subject = 'Text plain email with quoted url';
  static const String body = 'aa.aa#"style="x"';
  static const String linkStyle = 'white-space: nowrap; word-break: keep-all;';

  @override
  Future<void> runTestLogic() async {
    await waitForMailboxReady();
    await JmapTextPlainEmailProvisioner().create(subject: subject, body: body);
    await Get.find<ThreadController>().refreshAllEmail(
      shouldClearCache: PlatformInfo.isWeb,
    );

    await robots.threadRobot().openEmailWithSubject(subject);
    await $.pumpAndSettle(duration: const Duration(seconds: 3));

    final html = _renderedHtml();
    final document = html_parser.parse(html).body!;
    final link = document.querySelector('a');
    expect(link, isNotNull, reason: html);
    expect(link!.attributes['style'], linkStyle, reason: html);
    expect(document.text, contains(body), reason: html);
  }

  String _renderedHtml() {
    final onWeb = find.byType(HtmlContentViewerOnWeb).evaluate();
    if (onWeb.isNotEmpty) {
      return (onWeb.first.widget as HtmlContentViewerOnWeb).contentHtml;
    }
    final viewers = find.byType(HtmlContentViewer).evaluate();
    if (viewers.isNotEmpty) {
      return (viewers.first.widget as HtmlContentViewer).contentHtml;
    }
    throw StateError('no html viewer mounted');
  }
}
