/// Removed once the dashboard moves to Riverpod.
abstract interface class AccountSwitchDashboard {
  bool get hasOpenComposer;

  void resetForNewAccount();

  /// Labels of the account already selected for this switch (session setup has its own path).
  void reloadLabelSettingForShownAccount();
}
