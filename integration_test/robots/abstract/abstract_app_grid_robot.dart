abstract class AbstractAppGridRobot {
  List<String> get appNames;
  Future<void> expectAppCountAndLabelsMatch();
  Future<void> expectListViewVisible();
  Future<void> openAppInAppGrid();
}