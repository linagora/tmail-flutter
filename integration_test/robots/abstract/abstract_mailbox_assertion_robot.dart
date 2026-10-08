import 'package:patrol/patrol.dart';

abstract class AbstractMailboxAssertionRobot {
  Future<void> expectMailboxVisible(PatrolFinder finder);
  Future<void> expectSubfolderNotExist(PatrolFinder finder);
  Future<void> expectPersonalInboxSelected();
  Future<void> expectTeamMailboxCollapsed(String teamMailboxEmail);
  Future<void> expectTeamMailboxChildVisible(
    String teamMailboxEmail,
    String childName,
  );
}
