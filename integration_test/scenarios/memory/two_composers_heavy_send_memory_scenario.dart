import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/prefix_email_address.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';

import '../../memory/heavy_png.dart';
import '../../utils/send_and_wait_for_completion.dart';
import '../../utils/test_timeouts.dart';
import '../../utils/wait_for_condition.dart';
import 'memory_leak_scenario.dart';

/// Composers run one after the other on every platform; concurrent web
/// composers are not covered.
class TwoComposersHeavySendMemoryScenario extends MemoryLeakScenario {
  const TwoComposersHeavySendMemoryScenario(super.$, super.robots);

  static const _recipient = String.fromEnvironment('ADDITIONAL_MAIL_RECIPIENT');

  @override
  String get caseId => 'two_composers_heavy_send';

  @override
  Future<void> runCycle(MemoryCycle cycle) async {
    final composers = cycle == MemoryCycle.measured ? 2 : 1;
    for (var index = 0; index < composers; index++) {
      await _composeAndSend(
        'Memory composer ${cycle.name} $index',
        isFirstComposer: cycle == MemoryCycle.warmup && index == 0,
      );
    }
  }

  Future<void> _composeAndSend(
    String subject, {
    required bool isFirstComposer,
  }) async {
    final composerRobot = robots.composerRobot();
    await robots.threadRobot().openComposer();
    await composerRobot.expectComposerViewVisible();
    // The slow emulator can show the dialog late; a request left pending would
    // make the next composer's request fail with "already running".
    await composerRobot.grantContactPermission(
      timeout: isFirstComposer ? TestTimeouts.medium : const Duration(seconds: 2),
    );
    // Typing a free-text address creates no chip on headless web, and the
    // contact suggestion for this address is not reliable: the recipient is
    // set up through the controller, as the widget does when a chip is added.
    composerRobot.findComposerController()!.updateListEmailAddress(
      PrefixEmailAddress.to,
      [EmailAddress(null, _recipient)],
    );
    await composerRobot.addSubject(subject);
    await waitForCondition(
      () => composerRobot.findComposerController()?.subjectEmail.value == subject,
      reason: 'Subject should reach the composer controller',
    );
    await composerRobot.addContent('heavy');
    await composerRobot.addInlineFromBytes(heavyImageBytes, 'inline.png');
    await composerRobot.addAttachmentFromBytes(
      heavyImageBytes,
      'attachment.png',
    );
    await composerRobot.waitForAttachmentsUploaded();
    await sendAndWaitForCompletion($, composerRobot);
    // The next composer must not open while this one is still closing: its view
    // rebuilds after the controller is disposed and throws a null check.
    await waitForCondition(
      () => !$(ComposerView).exists,
      reason: 'The composer should close after sending',
    );
  }
}
