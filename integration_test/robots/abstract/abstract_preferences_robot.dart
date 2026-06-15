abstract class AbstractPreferencesRobot {
  Future<void> togglePreferenceOption(String title);
  Future<void> expectPreferenceOption(String title, {required bool switchedOn});
}