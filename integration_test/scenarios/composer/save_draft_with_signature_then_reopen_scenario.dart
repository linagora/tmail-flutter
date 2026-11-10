import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_identity.dart';
import '../../robots/web/web_composer_robot.dart';
import '../../robots/web/web_composer_signature_assertion_robot.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';
import 'save_draft_by_closing_composer_mixin.dart';

class SaveDraftWithSignatureThenReopenScenario extends BaseTestScenario
    with SaveDraftByClosingComposerMixin {
  const SaveDraftWithSignatureThenReopenScenario(super.$, super.robots);

  static const _signatureMarker = 'DRAFT_SIGNATURE_MARKER';

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    if (email.isEmpty) throw StateError('BASIC_AUTH_EMAIL must not be empty');

    final subject =
        'Draft with signature ${DateTime.now().microsecondsSinceEpoch}';
    // Web-only scenario creates the platform robot directly (e2e guide).
    final composerRobot = WebComposerRobot($);
    final signatureAssertion = WebComposerSignatureAssertionRobot($);
    final threadRobot = robots.threadRobot();
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final l10n = AppLocalizations();

    await provisionIdentities([
      ProvisioningIdentity(
        identity: Identity(
          name: 'Draft Signature Identity',
          email: email,
          htmlSignature: Signature(_signatureMarker),
          sortOrder: UnsignedInt(0),
        ),
        isDefault: true,
      ),
    ]);
    await robots.commonRobot().waitForMailboxReady();

    await threadRobot.openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();
    // Wait for the identity marker before other edits. Do not call addContent
    // via web enterText here: it replaces note-editable and wipes the signature.
    await composerRobot.waitForSignatureMarker(_signatureMarker);
    await composerRobot.addRecipient(PrefixEmailAddress.to, email);
    await composerRobot.addSubject(subject);
    // Confirm the signature survived recipient/subject edits before saving.
    await composerRobot.waitForSignatureMarker(_signatureMarker);

    await saveDraftByClosingComposer(composerRobot, l10n);

    await mailboxMenuRobot.navigation.openFolder(
      mailboxMenuRobot.mailboxItemByName(l10n.draftsMailboxDisplayName),
    );
    await waitForCondition(
      () => $(subject).exists,
      timeout: TestTimeouts.long,
      reason: 'saved draft $subject to appear in Drafts',
    );
    await threadRobot.openEmailWithSubject(subject);
    await composerRobot.expectComposerViewVisible();
    // Assertion robot owns the reopen visibility wait + expects (not a second
    // identical waitForSignatureMarker that would make the expects vacuous).
    await signatureAssertion.expectSingleVisibleSignature(_signatureMarker);

    // Reopening is not an edit: closing now must not ask to save again.
    await composerRobot.expectComposerClosedWithoutSavePrompt();
  }
}
