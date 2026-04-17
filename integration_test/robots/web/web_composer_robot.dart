import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/composer/presentation/widgets/web/web_editor_widget.dart';

import '../mobile/mobile_composer_robot.dart';

/// Web-specific composer robot. Overrides [addContent] because InAppWebView
/// is unavailable on web — content is injected via Patrol's web automator.
class WebComposerRobot extends MobileComposerRobot {
  WebComposerRobot(PatrolIntegrationTester $) : super($);

  @override
  Future<void> addContent(String content) async {
    await $(WebEditorWidget).tap();
    await $.platformAutomator.web.enterText(
      WebSelector(cssOrXpath: 'div.note-editable'),
      iframeSelector: WebSelector(cssOrXpath: 'iframe'),
      text: content,
    );
  }
}
