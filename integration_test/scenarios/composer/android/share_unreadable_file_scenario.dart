import 'package:flutter_test/flutter_test.dart';
import 'package:model/email/email_action_type.dart';
import 'package:tmail_ui_user/features/composer/presentation/composer_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../../base/base_test_scenario.dart';
import '../../../utils/receive_sharing_intent_simulator.dart';
import '../../../utils/wait_for_condition.dart';
import '../../../utils/wait_for_mailbox_ready.dart';

/// Simulates an Android share that carries one uri the app cannot read, next to
/// a text when [sharedText] is set, and asserts the error toast shows, the text
/// still opens the composer, and an unreadable-only share opens none.
class ShareUnreadableFileScenario extends BaseTestScenario {
  const ShareUnreadableFileScenario(super.$, super.robots, {this.sharedText});

  final String? sharedText;

  static const _unreadableUri = 'content://com.example.provider/secret.pdf';

  @override
  Future<void> runTestLogic() async {
    final composerRobot = robots.composerRobot();

    await waitForMailboxReady();

    await emitSharedMediaEvent([
      sharedMediaMap(path: _unreadableUri, type: 'unreadable'),
      if (sharedText != null)
        sharedMediaMap(path: sharedText!, type: 'text', mimeType: 'text/plain'),
    ]);
    await $.pumpAndTrySettle();

    await expectViewVisible(
      $(find.text(AppLocalizations().sharedFilesCannotBeRead(1))),
    );

    if (sharedText == null) {
      expect($(ComposerView).exists, isFalse);
      return;
    }

    await expectViewVisible($(ComposerView));
    await waitForCondition(() =>
        composerRobot.findComposerController()?.currentEmailActionType ==
        EmailActionType.composeFromContentShared);
    expect(
      composerRobot.findComposerController()?.composerArguments.value?.emailContents,
      sharedText,
    );
  }
}
