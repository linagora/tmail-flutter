import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

import '../../../base/base_test_scenario.dart';
import '../../../utils/receive_sharing_intent_simulator.dart';
import '../../../utils/test_timeouts.dart';
import '../../../utils/wait_for_condition.dart';
import '../../../utils/wait_for_mailbox_ready.dart';

/// Simulates a `mailto:` link tapped in an external browser while Twake
/// Mail's process is already running but the user hasn't reached the
/// mailbox yet (login/session still in flight) — the scenario a real user
/// hits when the app was previously opened and is still warm in the
/// background, but not currently showing the mailbox.
///
/// Guards the regression where `MailboxDashBoardController` was the only
/// subscriber to the live `receive_sharing_intent` EventChannel: a share
/// emitted before that controller existed was silently dropped, since
/// EventChannel streams don't replay events emitted before a listener
/// attaches. The fix moves the buffering into `EmailReceiveManager`,
/// started at `HomeController.onInit()` (effectively app boot), so it is
/// already listening by the time this scenario emits the share.
class ShareMailtoBeforeMailboxReadyOpensComposerScenario extends BaseTestScenario {
  ShareMailtoBeforeMailboxReadyOpensComposerScenario(super.$, super.robots);

  late final Future<void> _shareStreamListened;

  @override
  Future<void> prepare() async {
    // Armed before the app mounts so the share goes out the moment HomeController subscribes.
    _shareStreamListened = waitForSharedMediaStreamListen();
    await super.prepare();
  }

  @override
  Future<void> runTestLogic() async {
    final composerRobot = robots.composerRobot();

    await _shareStreamListened.timeout(
      TestTimeouts.medium,
      onTimeout: () => fail('the app never subscribed to the shared-media stream'),
    );
    expect(
      Get.isRegistered<MailboxDashBoardController>() &&
          !Get.isPrepared<MailboxDashBoardController>(),
      isFalse,
      reason: 'the share must arrive before the mailbox controller exists',
    );

    // Emitted before the mailbox controller exists — must not be dropped.
    await emitSharedMediaEvent([
      sharedMediaMap(
        path: 'mailto:shared-recipient@example.com?subject=Hello&body=World',
        type: 'url',
      ),
    ]);

    await waitForMailboxReady();
    await $.pumpAndTrySettle();

    // The composer must open with the share that arrived before the mailbox
    // was ready — before the fix, this share was dropped and nothing opened.
    await expectViewVisible($(ComposerView));

    await waitForCondition(() =>
        composerRobot.findComposerController()?.currentEmailActionType ==
        EmailActionType.composeFromMailtoUri);

    final composerArguments =
        composerRobot.findComposerController()?.composerArguments.value;
    expect(
      composerArguments?.listEmailAddress,
      [EmailAddress(null, 'shared-recipient@example.com')],
    );
    expect(composerArguments?.subject, 'Hello');
    expect(composerArguments?.body, 'World');
  }
}
