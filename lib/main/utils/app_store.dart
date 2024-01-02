
import 'package:shared_preferences/shared_preferences.dart';

class AppStore {
  final SharedPreferences _preferences;

  AppStore(this._preferences);

  Future<bool> getItemBoolean(String key, {bool? defaultValue}) async {
    return _preferences.getBool(key) ?? defaultValue ?? false;
  }

  Future<void> setItemBoolean(String key, bool value) async {
    await _preferences.setBool(key, value);
  }
}