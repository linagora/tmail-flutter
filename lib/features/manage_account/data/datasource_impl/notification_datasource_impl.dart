import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/notification_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/notification_setting_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/exceptions/notification_exceptions.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';

class NotificationDataSourceImpl implements NotificationDataSource {
  final NotificationSettingCacheManager _notificationSettingCacheManager;
  final ExceptionThrower _exceptionThrower;

  NotificationDataSourceImpl(this._notificationSettingCacheManager, this._exceptionThrower);

  @override
  Future<bool> getAppNotificationSetting() {
    return Future.sync(() async {
      final cache = _notificationSettingCacheManager.getAppNotificationSettingCache();
      if (cache != null) return cache;

      final current = await Permission.notification.status;
      switch (current) {
        case PermissionStatus.granted:
          await _notificationSettingCacheManager.persistAppNotificationSettingCache(true);
          return true;
        case PermissionStatus.denied:
          final requestResult = await Permission.notification.request();
          final permissionGranted = requestResult == PermissionStatus.granted;
          await _notificationSettingCacheManager.persistAppNotificationSettingCache(permissionGranted);
          return permissionGranted;
        default:
          await _notificationSettingCacheManager.persistAppNotificationSettingCache(false);
          return false;
      }
    }).catchError(_exceptionThrower.throwException);
  }
  
  @override
  Future<void> toggleAppNotificationSetting(bool isEnabled) async {
    return Future.sync(() async {
      if (!isEnabled) {
        return await _notificationSettingCacheManager.persistAppNotificationSettingCache(false);
      }

      final current = await Permission.notification.status;
      switch (current) {
        case PermissionStatus.granted:
          return await _notificationSettingCacheManager.persistAppNotificationSettingCache(true);
        case PermissionStatus.denied:
          final requestResult = await Permission.notification.request();
          final permissionGranted = requestResult == PermissionStatus.granted;
          if (permissionGranted) {
            return await _notificationSettingCacheManager.persistAppNotificationSettingCache(true);
          }
          throw const NotificationPermissionDeniedException();
        default:
          throw const NotificationPermissionDeniedException();
      }
    }).catchError(_exceptionThrower.throwException);
  }
  
  @override
  Future<bool> attemptToggleSystemNotificationSetting() async {
    return Future.sync(() async {
      await openAppSettings();

      final current = await Permission.notification.status;
      switch (current) {
        case PermissionStatus.granted:
          await _notificationSettingCacheManager.persistAppNotificationSettingCache(true);
          return true;
        case PermissionStatus.denied:
          final requestResult = await Permission.notification.request();
          final permissionGranted = requestResult == PermissionStatus.granted;
          await _notificationSettingCacheManager.persistAppNotificationSettingCache(permissionGranted);
          return permissionGranted;
        default:
          await _notificationSettingCacheManager.persistAppNotificationSettingCache(false);
          return false;
      }
    }).catchError(_exceptionThrower.throwException);
  }
}