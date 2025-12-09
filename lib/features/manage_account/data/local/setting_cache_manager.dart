import 'package:shared_preferences/shared_preferences.dart';

class SettingCacheManager {
  static const String _labelVisibilitySettingKey = 'LABEL_VISIBILITY';

  const SettingCacheManager(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  Future<bool> getLabelVisibility() async {
    await _sharedPreferences.reload();
    return _sharedPreferences.getBool(_labelVisibilitySettingKey) ?? false;
  }

  Future<void> saveLabelVisibility(bool visible) async {
    await _sharedPreferences.setBool(_labelVisibilitySettingKey, visible);
  }
}
