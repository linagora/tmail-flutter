import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_controller.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../models/provisioning_identity.dart';
import '../../robots/email_robot.dart';
import '../../robots/thread_robot.dart';

class ReplyInlineFocusedWithSignatureInsertsUnderSignatureScenario
    extends BaseTestScenario {
  const ReplyInlineFocusedWithSignatureInsertsUnderSignatureScenario(
      super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const subject = 'reply inline with signature';
    const signatureMarker = 'SIGNATURE_MARKER';
    final threadRobot = ThreadRobot($);
    final emailRobot = EmailRobot($);
    final png = await preparingPngWithName('inline-png');

    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    await provisionIdentities([
      ProvisioningIdentity(
        identity: Identity(
          name: 'Test Identity',
          email: email,
          htmlSignature: Signature(signatureMarker),
        ),
        isDefault: true,
      ),
    ]);
    await provisionEmail([
      ProvisioningEmail(
        toEmail: email,
        subject: subject,
        content: 'body',
      ),
    ], requestReadReceipt: false);

    await threadRobot.openEmailWithSubject(subject);
    await emailRobot.onTapReplyEmail();
    await robots.composerRobot().expectComposerViewVisible();
    await robots.composerRobot().grantContactPermission();
    await robots.composerRobot().waitForSignatureToLoad();
    await robots.composerRobot().focusEditorAboveReplyBody();
    await robots.composerRobot().addInlineAtCursorPosition(png);

    final html = await Get.find<ComposerController>().getContentInEditor();
    _expectSignatureExists(html);
    _expectInlineExists(html);
    _expectBlockquoteExists(html);
    _expectSignatureAboveInline(html);
    _expectInlineAboveBlockquote(html);
  }

  void _expectSignatureExists(String html) {
    final sigIdx = html.indexOf('SIGNATURE_MARKER');
    expect(sigIdx, greaterThan(-1));
  }

  void _expectInlineExists(String html) {
    final imgIdx = html.indexOf('data:image/');
    expect(imgIdx, greaterThan(-1));
  }

  void _expectBlockquoteExists(String html) {
    final bqIdx = html.indexOf('<blockquote');
    expect(bqIdx, greaterThan(-1));
  }

  void _expectSignatureAboveInline(String html) {
    final sigIdx = html.indexOf('SIGNATURE_MARKER');
    final imgIdx = html.indexOf('data:image/');
    expect(sigIdx, lessThan(imgIdx));
  }

  void _expectInlineAboveBlockquote(String html) {
    final imgIdx = html.indexOf('data:image/');
    final bqIdx = html.indexOf('<blockquote');
    expect(imgIdx, lessThan(bqIdx));
  }
}
