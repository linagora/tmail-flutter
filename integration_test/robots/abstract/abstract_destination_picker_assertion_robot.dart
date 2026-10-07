import 'package:patrol/patrol.dart';

abstract class AbstractDestinationPickerAssertionRobot {
  Future<void> expectFolderVisible(PatrolFinder finder);
  void expectFolderAbsent(PatrolFinder finder);
  Future<void> expectPickerClosed();
}
