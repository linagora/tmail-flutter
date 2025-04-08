import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/mailbox_view.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../../base/base_test_scenario.dart';
import '../../robots/mailbox_menu_robot.dart';
import '../../robots/thread_robot.dart';

class SearchMailboxInboxScenario extends BaseTestScenario {
  const SearchMailboxInboxScenario(super.$);

  @override
  Future<void> runTestLogic() async {
    final threadRobot = ThreadRobot($);
    final mailboxMenuRobot = MailboxMenuRobot($);
    final appLocalizations = AppLocalizations();

    await threadRobot.openMailbox();
    await _expectMailboxViewVisible();

    await _expectMailboxWithNameVisible(appLocalizations.inboxMailboxDisplayName);
    await mailboxMenuRobot.openMailboxSearch();
    await mailboxMenuRobot.searchMailbox(appLocalizations.inboxMailboxDisplayName);
    await _expectMailboxWithNameVisible(appLocalizations.inboxMailboxDisplayName);
  }

  Future<void> _expectMailboxViewVisible() async {
    await expectViewVisible($(MailboxView));
  }

  Future<void> _expectMailboxWithNameVisible(String name) async {
    await expectViewVisible($(name));
  }
} 