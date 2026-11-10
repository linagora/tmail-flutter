import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_identity.dart';
import '../../robots/web/web_composer_robot.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';
import 'save_draft_by_closing_composer_mixin.dart';

/// A draft saved with an identity that has no signature still carries the
/// identity header. Reopening it is not an edit, so closing right away must
/// not ask to save the draft again.
class ReopenDraftWithIdentityWithoutSignatureScenario extends BaseTestScenario
    with SaveDraftByClosingComposerMixin {
  const ReopenDraftWithIdentityWithoutSignatureScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const email = String.fromEnvironment('BASIC_AUTH_EMAIL');
    if (email.isEmpty) throw StateError('BASIC_AUTH_EMAIL must not be empty');

    final subject =
        'Draft without signature ${DateTime.now().microsecondsSinceEpoch}';
    final composerRobot = WebComposerRobot($);
    final threadRobot = robots.threadRobot();
    final mailboxMenuRobot = robots.mailboxMenuRobot();
    final l10n = AppLocalizations();

    await provisionIdentities([
      ProvisioningIdentity(
        identity: Identity(
          name: 'Identity Without Signature',
          email: email,
          sortOrder: UnsignedInt(0),
        ),
        isDefault: true,
      ),
    ]);
    await robots.commonRobot().waitForMailboxReady();

    await threadRobot.openComposer();
    await composerRobot.expectComposerViewVisible();
    await composerRobot.grantContactPermission();
    await composerRobot.addRecipient(PrefixEmailAddress.to, email);
    await composerRobot.addSubject(subject);

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
    // Closing before the body loads skips the prompt for an unrelated reason.
    await $.pumpAndTrySettle(duration: const Duration(seconds: 3));

    await composerRobot.expectComposerClosedWithoutSavePrompt();
  }
}
