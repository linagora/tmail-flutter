import '../../base/base_test_scenario.dart';

class TapTeamMailboxRootScenario extends BaseTestScenario {
  const TapTeamMailboxRootScenario(super.$, super.robots);

  static const _teamMailboxName = 'bob-guests';
  static const _teamMailboxEmail = '$_teamMailboxName@example.com';
  static const _teamInboxName = 'INBOX';

  @override
  Future<void> runTestLogic() async {
    final threadRobot = robots.threadRobot();
    final mailboxMenuRobot = robots.mailboxMenuRobot();

    await threadRobot.openMailbox();
    await mailboxMenuRobot.assertion.expectPersonalInboxSelected();
    await mailboxMenuRobot.assertion.expectTeamMailboxCollapsed(_teamMailboxEmail);

    await mailboxMenuRobot.navigation.tapMailbox(
      mailboxMenuRobot.mailboxItemByName(_teamMailboxName),
    );

    await mailboxMenuRobot.assertion.expectTeamMailboxChildVisible(
      _teamMailboxEmail,
      _teamInboxName,
    );
    await mailboxMenuRobot.assertion.expectPersonalInboxSelected();
  }
}
