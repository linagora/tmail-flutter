import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';

import '../../../base/base_test_scenario.dart';
import '../../../utils/receive_sharing_intent_simulator.dart';
import '../../../utils/wait_for_condition.dart';
import '../../../utils/wait_for_mailbox_ready.dart';

/// Simulates an external app sharing plain text into the mailbox and asserts the
/// composer opens with that text as the body.
///
/// Guards the regression where a text share whose mimeType is not exactly
/// `text/plain` (e.g. `text/plain;charset=utf-8`, `text/html`) was dropped and
/// the composer never opened.
///
/// The share is delivered through the real `receive_sharing_intent` EventChannel,
/// so the app's own stream wiring runs (getMediaStream -> EmailReceiveManager ->
/// MailboxDashBoardController -> openComposer).
class ShareTextFromExternalOpensComposerScenario extends BaseTestScenario {
  const ShareTextFromExternalOpensComposerScenario(
    super.$,
    super.robots, {
    required this.sharedText,
    required this.mimeType,
  });

  final String sharedText;
  final String mimeType;

  @override
  Future<void> runTestLogic() async {
    final composerRobot = robots.composerRobot();

    await waitForMailboxReady();

    await emitSharedMediaEvent([
      sharedMediaMap(path: sharedText, type: 'text', mimeType: mimeType),
    ]);
    await $.pumpAndTrySettle();

    // The composer must open — before the fix a non-plain text mimeType opened
    // nothing.
    await expectViewVisible($(ComposerView));

    // And the shared text must be routed as body content (not dropped/attached).
    await waitForCondition(() =>
        composerRobot.findComposerController()?.currentEmailActionType ==
        EmailActionType.composeFromContentShared);
    expect(
      composerRobot.findComposerController()?.composerArguments.value?.emailContents,
      sharedText,
    );
  }
}
