import 'package:core/utils/app_logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingCacheManager {
  static const keyAppNotificationSettingCode = 'KEY_APP_NOTIFICATION_SETTING_CODE';

  final SharedPreferences _sharedPreferences;

  NotificationSettingCacheManager(this._sharedPreferences);

  Future<void> persistAppNotificationSettingCache(bool isEnabled) async {
    await _sharedPreferences.setBool(
      keyAppNotificationSettingCode,
      isEnabled);
  }

  bool? getAppNotificationSettingCache() {
    return _sharedPreferences.getBool(keyAppNotificationSettingCode);
  }

  Future<void> removeAppNotificationSettingCache() async {
    try {
      await _sharedPreferences.remove(keyAppNotificationSettingCode);
    } on Exception catch (error) {
      log('NotificationCacheManager::removeAppNotificationSettingCache(): error: $error');
    }
  }
}