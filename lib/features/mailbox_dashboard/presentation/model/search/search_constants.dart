class SearchConstants {
  /// Debounce for the email search bar. The suggestion fetch and the input→SSOT
  /// commit share this cadence so both settle on the same query value before it
  /// runs. Keep them equal by referencing this single constant.
  static const inputDebounceDuration = Duration(milliseconds: 300);
}
