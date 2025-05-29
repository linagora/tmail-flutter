import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/local_setting_options.dart';

class LocalSettingCacheManager {
  const LocalSettingCacheManager(this._sharedPreferences);

  final SharedPreferences _sharedPreferences;

  static const key = 'local_setting';

  Future<void> update(LocalSettingOptions localSettingOptions) async {
    await _sharedPreferences.setString(
      key,
      jsonEncode(localSettingOptions.toJson()),
    );
  }

  Future<LocalSettingOptions> get() async {
    final data = _sharedPreferences.getString(key);
    if (data == null) {
      return LocalSettingOptions.defaults();
    }
    return LocalSettingOptions.fromJson(jsonDecode(data));
  }
}