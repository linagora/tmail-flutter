abstract class AbstractAppGridRobot {
  List<String> get appNames;
  Future<void> expectListViewAppGridVisible();
  Future<void> expectAllAppInAppGridDisplayedIsFull();
  Future<void> openAppInAppGrid();
}