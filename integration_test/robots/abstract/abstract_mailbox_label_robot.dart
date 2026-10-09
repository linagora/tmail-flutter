import 'package:patrol/patrol.dart';

abstract class AbstractMailboxLabelRobot {
  Future<void> openLabel(PatrolFinder label);
  Future<void> openLabelContextMenu(PatrolFinder label);
  Future<void> tapLabelAction(String actionName);
  Future<void> confirmDeleteLabel();
  Future<void> enterLabelName(String name);
  Future<void> tapSaveLabel();
}
