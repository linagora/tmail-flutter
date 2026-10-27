abstract class AbstractSearchInputRobot {
  Future<void> tapOnSearchField();
  // Taps again when the dashboard takes focus back after its first load.
  Future<void> focusSearchField();
  Future<void> enterKeyword(String keyword);
  // On web, the suggestion overlay is not hit-testable — press Enter instead of tapping.
  Future<void> tapOnShowAllResultsText();
}
