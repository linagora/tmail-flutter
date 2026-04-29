import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../robots/email_robot.dart';
import '../../robots/thread_robot.dart';

class ReplyInlineNoFocusAtFirstLineScenario extends BaseTestScenario {
  const ReplyInlineNoFocusAtFirstLineScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const subject = 'reply inline no focus';
    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);
    final png = await preparingPngWithName('inline-png');

    await provisionEmail([
      ProvisioningEmail(
        toEmail: const String.fromEnvironment('BASIC_AUTH_EMAIL'),
        subject: subject,
        content: 'body',
      ),
    ], requestReadReceipt: false);

    await threadRobot.openEmailWithSubject(subject);
    await emailRobot.onTapReplyEmail();
    await robots.composerRobot().expectComposerViewVisible();
    await robots.composerRobot().grantContactPermission();
    // [do NOT focus editor — tests the no-focus code path]
    await robots.composerRobot().addInlineAtCursorPosition(png);

    await _expectInlineAboveBlockquote();
  }

  Future<void> _expectInlineAboveBlockquote() async {
    final html = await Get.find<ComposerController>().getContentInEditor();
    final imgIdx = html.indexOf('data:image/');
    final bqIdx = html.indexOf('<blockquote');
    expect(imgIdx, greaterThan(-1));
    expect(bqIdx, greaterThan(-1));
    expect(imgIdx, lessThan(bqIdx));
  }
}
