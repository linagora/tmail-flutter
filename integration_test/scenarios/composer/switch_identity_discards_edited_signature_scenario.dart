import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_identity.dart';

class SwitchIdentityDiscardsEditedSignatureScenario extends BaseTestScenario {
  const SwitchIdentityDiscardsEditedSignatureScenario(super.$, super.robots);

  static const _firstMarker = 'SIG_ONE_MARKER';
  static const _secondMarker = 'SIG_TWO_MARKER';
  static const _editedText = 'EDITED_BY_USER';
  static const _secondIdentityName = 'Identity 2';

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    if (email.isEmpty) throw StateError('BASIC_AUTH_EMAIL must not be empty');

    final composerRobot = robots.composerRobot();
    final signatureRobot = composerRobot.signature!;

    await provisionIdentities([
      ProvisioningIdentity(
        identity: Identity(
          name: 'Identity 1',
          email: email,
          htmlSignature: Signature(_firstMarker),
          sortOrder: UnsignedInt(0),
        ),
        isDefault: true,
      ),
      ProvisioningIdentity(
        identity: Identity(
          name: _secondIdentityName,
          email: email,
          htmlSignature: Signature(_secondMarker),
          sortOrder: UnsignedInt(100),
        ),
      ),
    ]);
    await robots.commonRobot().waitForMailboxReady();

    await robots.threadRobot().openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();
    await signatureRobot.waitForSignatureMarker(_firstMarker);

    await signatureRobot.editSignature(_firstMarker, _editedText);
    await signatureRobot.switchIdentity(_secondIdentityName);

    await signatureRobot.expectOnlySignature(
      _secondMarker,
      absentText: [_firstMarker, _editedText],
    );
  }
}
