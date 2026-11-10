import 'package:jmap_dart_client/jmap/identities/identity.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_email.dart';
import '../../models/provisioning_identity.dart';
import '../../robots/email_robot.dart';

/// A reply composer holds the identity signature plus the quoted message. None
/// of that is a user edit, so closing right away must not ask to save.
class CloseUnmodifiedReplyWithSignatureScenario extends BaseTestScenario {
  const CloseUnmodifiedReplyWithSignatureScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    if (email.isEmpty) throw StateError('BASIC_AUTH_EMAIL must not be empty');
    const subject = 'close unmodified reply with signature';

    await provisionIdentities([
      ProvisioningIdentity(
        identity: Identity(
          name: 'Close Reply Identity',
          email: email,
          htmlSignature: Signature('CLOSE_REPLY_SIGNATURE_MARKER'),
        ),
        isDefault: true,
      ),
    ]);
    await robots.commonRobot().provisionEmail([
      ProvisioningEmail(toEmail: email, subject: subject, content: 'body'),
    ], requestReadReceipt: false);

    await robots.threadRobot().openEmailWithSubject(subject);
    await EmailRobot($).onTapReplyEmail();

    final composerRobot = robots.composerRobot();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();
    await composerRobot.waitForSignatureToLoad();

    await composerRobot.expectComposerClosedWithoutSavePrompt();
  }
}
