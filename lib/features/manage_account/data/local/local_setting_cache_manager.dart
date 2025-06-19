import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';

class LocalSettingCacheManager {
  const LocalSettingCacheManager(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  Future<void> update(
    Map<SupportedLocalSetting, LocalSettingOptions?> localSettings,
  ) async {
    await Future.wait(localSettings.entries.map((entry) async {
      if (entry.value == null) {
        await _sharedPreferences.remove(entry.key.name);
        return;
      }

      await _sharedPreferences.setString(
        entry.key.name,
        jsonEncode(entry.value!.toJson()),
      );
    }));
  }

  Future<Map<SupportedLocalSetting, LocalSettingOptions?>> get(
    List<SupportedLocalSetting> supportedLocalSettings,
  ) async {
    await _sharedPreferences.reload();
    
    return Map.fromEntries(supportedLocalSettings.map((supportedLocalSetting) {
      final data = _sharedPreferences.getString(supportedLocalSetting.name);

      return MapEntry(
        supportedLocalSetting,
        data == null ? null : LocalSettingOptions.fromJson(jsonDecode(data)),
      );
    }));
  }
}