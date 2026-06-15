abstract class AbstractSettingsRobot {
  Future<void> openPreferencesMenuItem();
  Future<void> togglePreference(String title);
  Future<void> expectPreference(String title, {required bool switchedOn});
}