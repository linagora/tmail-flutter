import 'package:model/email/prefix_email_address.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/abstract/abstract_composer_reload_robot.dart';
import '../../robots/abstract/abstract_composer_robot.dart';

typedef _ComposerInput = ({String subject, String recipient, String body});

class RestoreComposerAfterReloadScenario extends BaseTestScenario {
  const RestoreComposerAfterReloadScenario(super.$, super.robots);

  @override
  Future<void> runTestLogic() async {
    const recipient = String.fromEnvironment('BASIC_AUTH_EMAIL');
    assert(recipient.isNotEmpty, 'BASIC_AUTH_EMAIL must not be empty');
    final input = (
      subject: 'Reload subject ${DateTime.now().microsecondsSinceEpoch}',
      recipient: recipient,
      body: 'Composer body survives reload',
    );

    await robots.commonRobot().waitForMailboxReady();
    final composerRobot = robots.composerRobot();
    final reloadRobot = composerRobot.reload!;
    await robots.threadRobot().openComposer();
    await composerRobot.expectComposerViewVisible();
    reloadRobot.captureCurrentComposer();

    await _stepEnterContent(composerRobot, reloadRobot, input);
    reloadRobot.assertion.expectSnapshotAbsent();
    reloadRobot.dispatchBeforeUnload();
    reloadRobot.assertion.expectSnapshotPresent();

    await _stepRestoreComposer(reloadRobot);
    await _expectRestoredComposer(reloadRobot, input);
    await _stepCloseComposer(composerRobot, reloadRobot);
  }

  Future<void> _stepEnterContent(
    AbstractComposerRobot composerRobot,
    AbstractComposerReloadRobot reloadRobot,
    _ComposerInput input,
  ) async {
    await composerRobot.addRecipient(PrefixEmailAddress.to, input.recipient);
    await composerRobot.addSubject(input.subject);
    await composerRobot.addContent(input.body);
    await reloadRobot.waitForContentReady(
      input.subject,
      input.recipient,
      input.body,
    );
  }

  Future<void> _stepRestoreComposer(
    AbstractComposerReloadRobot reloadRobot,
  ) async {
    reloadRobot.tearDownWithoutClose();
    await reloadRobot.assertion.expectComposerAbsent();
    reloadRobot.assertion.expectSnapshotPresent();
    await reloadRobot.restoreFromCache();
    await reloadRobot.assertion.expectRestoredComposerVisible();
  }

  Future<void> _expectRestoredComposer(
    AbstractComposerReloadRobot reloadRobot,
    _ComposerInput input,
  ) async {
    await reloadRobot.assertion.expectRestoredContent(
      input.subject,
      input.recipient,
      input.body,
    );
    reloadRobot.assertion.expectSnapshotPresent();
  }

  Future<void> _stepCloseComposer(
    AbstractComposerRobot composerRobot,
    AbstractComposerReloadRobot reloadRobot,
  ) async {
    await composerRobot.tapCloseComposer();
    await $.pumpAndTrySettle();
    if (reloadRobot.assertion.isDiscardConfirmationVisible()) {
      await composerRobot.tapDiscardChanges();
    }
    await reloadRobot.assertion.expectSnapshotRemoved();
    await reloadRobot.assertion.expectComposerAbsent();
  }
}
