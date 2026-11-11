import 'package:jmap_dart_client/jmap/identities/identity.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_identity.dart';

/// Opening a new composer inserts the default identity signature. That is not a
/// user edit, so closing right away must not ask to save a draft.
class CloseUnmodifiedComposerWithSignatureScenario extends BaseTestScenario {
  const CloseUnmodifiedComposerWithSignatureScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    if (email.isEmpty) throw StateError('BASIC_AUTH_EMAIL must not be empty');

    await provisionIdentities([
      ProvisioningIdentity(
        identity: Identity(
          name: 'Close Signature Identity',
          email: email,
          htmlSignature: Signature('CLOSE_SIGNATURE_MARKER'),
        ),
        isDefault: true,
      ),
    ]);
    await robots.commonRobot().waitForMailboxReady();

    final composerRobot = robots.composerRobot();
    await robots.threadRobot().openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();
    // Closing before the body loads skips the prompt for an unrelated reason.
    await composerRobot.waitForSignatureToLoad();

    await composerRobot.expectComposerClosedWithoutSavePrompt();
  }
}
