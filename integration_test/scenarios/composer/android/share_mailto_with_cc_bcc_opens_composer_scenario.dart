import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';

import '../../../base/base_test_scenario.dart';
import '../../../utils/receive_sharing_intent_simulator.dart';
import '../../../utils/wait_for_condition.dart';
import '../../../utils/wait_for_mailbox_ready.dart';

/// Simulates a `mailto:` link with cc and bcc opened from another Android app
/// and asserts the composer keeps both recipient lists.
class ShareMailtoWithCcBccOpensComposerScenario extends BaseTestScenario {
  const ShareMailtoWithCcBccOpensComposerScenario(super.$, super.robots);

  static const _to = 'shared-to@example.com';
  static const _cc = 'shared-cc@example.com';
  static const _bcc = 'shared-bcc@example.com';

  @override
  Future<void> runTestLogic() async {
    final composerRobot = robots.composerRobot();

    await waitForMailboxReady();

    await emitSharedMediaEvent([
      sharedMediaMap(path: 'mailto:$_to?cc=$_cc&bcc=$_bcc', type: 'url'),
    ]);
    await $.pumpAndTrySettle();

    await expectViewVisible($(ComposerView));
    await waitForCondition(() =>
        composerRobot.findComposerController()?.currentEmailActionType ==
        EmailActionType.composeFromMailtoUri);

    // Assert the lists, not the chips: the subject autofocus collapses the fields.
    final controller = composerRobot.findComposerController();
    expect(controller?.listToEmailAddress, [EmailAddress(null, _to)]);
    expect(controller?.listCcEmailAddress, [EmailAddress(null, _cc)]);
    expect(controller?.listBccEmailAddress, [EmailAddress(null, _bcc)]);
  }
}
