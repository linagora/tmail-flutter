import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/label_mailbox_item_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_item_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class DisplayEmptyViewForFavoriteFolderScenario extends BaseTestScenario {
  const DisplayEmptyViewForFavoriteFolderScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();

    await threadRobot.openMailbox();
    await _expectFolderVisible(appLocalizations.favoriteMailboxDisplayName);

    await mailboxMenuRobot.openFolderByName(
      appLocalizations.favoriteMailboxDisplayName,
    );
    await $.pumpAndTrySettle();
    await _expectEmptyViewVisible();
  }

  Future<void> _expectFolderVisible(String folderName) {
    return expectViewVisible($(MailboxItemWidget)
        .$(LabelMailboxItemWidget)
        .$(find.text(folderName)));
  }

  Future<void> _expectEmptyViewVisible() =>
      expectViewVisible($(#empty_thread_view));
}
