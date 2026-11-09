abstract class AbstractPreferencesRobot {
  /// Setup so Delegation is visible. Today: 7-tap reveal; later: no-op.
  Future<void> ensureDelegationPreferenceReady();

  Future<void> togglePreferenceOption(String title);
  Future<void> expectPreferenceOption(String title, {required bool switchedOn});
}
