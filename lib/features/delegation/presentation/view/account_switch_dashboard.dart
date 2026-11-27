/// Removed once the dashboard moves to Riverpod.
abstract interface class AccountSwitchDashboard {
  bool get hasOpenComposer;

  /// Closes every composer without saving, drops its saved snapshot and returns how many were open.
  Future<int> closeComposers();

  void resetForNewAccount();

  /// Labels of the account already selected for this switch (session setup has its own path).
  void reloadLabelSettingForShownAccount();

  /// Contact autocomplete of the account already selected for this switch.
  void setUpAutocompleteForShownAccount();
}
