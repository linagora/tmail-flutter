import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences/preferences_root.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/preferences/spam_report_config.dart';

class PreferencesSettingManager {
  static const String _preferencesSettingKey = 'PREFERENCES_SETTING';

  const PreferencesSettingManager(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  Future<PreferencesRoot> loadPreferences() async {
    await _sharedPreferences.reload();

    final jsonString = _sharedPreferences.getString(_preferencesSettingKey);

    if (jsonString != null) {
      return PreferencesRoot.fromJson(jsonDecode(jsonString));
    }

    return PreferencesRoot.initial();
  }

  Future<void> savePreferences(PreferencesRoot root) async {
    await _sharedPreferences.setString(
      _preferencesSettingKey,
      jsonEncode(root.toJson()),
    );
  }

  Future<void> updateThread(bool enabled) async {
    final current = await loadPreferences();
    final updated = current.updateThreadDetail(enabled);
    await savePreferences(updated);
  }

  Future<void> updateSpamReport({
    bool? isEnabled,
    int? lastTimeDismissedMilliseconds,
  }) async {
    final current = await loadPreferences();
    final updated = current.updateSpamReport(
      isEnabled: isEnabled,
      lastTimeDismissedMilliseconds: lastTimeDismissedMilliseconds,
    );
    await savePreferences(updated);
  }

  Future<SpamReportConfig> getSpamReportConfig() async {
    final preferences = await loadPreferences();
    return preferences.setting.spamReport;
  }
}
