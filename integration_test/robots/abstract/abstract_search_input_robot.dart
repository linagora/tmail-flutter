abstract class AbstractSearchInputRobot {
  Future<void> tapOnSearchField();
  Future<void> enterKeyword(String keyword);
  // On web, the suggestion overlay is not hit-testable — press Enter instead of tapping.
  Future<void> tapOnShowAllResultsText();
}
