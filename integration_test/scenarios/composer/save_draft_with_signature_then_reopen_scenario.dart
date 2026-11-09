import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/identities/identity.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/domain/state/save_email_as_drafts_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../models/provisioning_identity.dart';
import '../../robots/web/web_composer_robot.dart';
import '../../robots/web/web_composer_signature_assertion_robot.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';

class SaveDraftWithSignatureThenReopenScenario extends BaseTestScenario {
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

    await _saveDraftByClosingComposer(composerRobot, l10n);

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
    await signatureAssertion.expectSignatureVisible(_signatureMarker);
  }

  /// Mirrors [BaseSaveDraftThenReopenScenario.performFirstSave]: subscribe
  /// before tapping Save so a momentary success state is not missed.
  Future<void> _saveDraftByClosingComposer(
    WebComposerRobot composerRobot,
    AppLocalizations l10n,
  ) async {
    await composerRobot.tapCloseComposer();
    await $.pumpAndTrySettle();
    await expectViewVisible($(#confirm_dialog_action));

    final dashboardController = Get.find<MailboxDashBoardController>();
    var saveSucceeded = false;
    final subscription = dashboardController.viewState.stream.listen((state) {
      state.fold((_) {}, (success) {
        if (success is SaveEmailAsDraftsSuccess) {
          saveSucceeded = true;
        }
      });
    });

    try {
      await composerRobot.tapSaveButtonOnSaveDraftConfirmDialog(l10n);
      // Confirm dialog reuses #confirm_dialog_action. Settle so a still-visible
      // confirm dialog is not treated as the failure signal.
      await $.pumpAndTrySettle();
      await waitForCondition(
        () => saveSucceeded || $(#confirm_dialog_action).visible,
        timeout: TestTimeouts.long,
        reason: 'draft save to succeed or show a failure dialog',
      );
    } finally {
      await subscription.cancel();
    }

    expect(
      saveSucceeded,
      isTrue,
      reason: 'draft save did not emit SaveEmailAsDraftsSuccess',
    );
    expect(
      $(#confirm_dialog_action).visible,
      isFalse,
      reason: 'draft save failed (confirm dialog still visible)',
    );
  }
}
