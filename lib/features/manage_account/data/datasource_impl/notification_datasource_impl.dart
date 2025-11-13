import 'package:app_settings/app_settings.dart';
import 'package:core/utils/platform_info.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/notification_datasource.dart';
import 'package:tmail_ui_user/main/exceptions/exception_thrower.dart';
import 'package:tmail_ui_user/main/permissions/notification_permission_service.dart';

class NotificationDataSourceImpl implements NotificationDataSource {
  final NotificationPermissionService _permissionService;
  final ExceptionThrower _exceptionThrower;

  NotificationDataSourceImpl(
    this._permissionService,
    this._exceptionThrower);

  @override
  Future<bool> getNotificationSetting(UserName userName) {
    return Future.sync(() async {
      if (PlatformInfo.isIOS) {
        return await _checkIosNotificationPermissionEnabled();
      } else {
        return await _checkAndroidNotificationPermissionEnabled(userName);
      }
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }
  
  @override
  Future<void> toggleNotificationSetting() async {
    return Future.sync(() async {
      return await AppSettings.openAppSettings(type: AppSettingsType.notification);
    }).catchError((error, stackTrace) async {
      await _exceptionThrower.throwException(error, stackTrace);
      throw error;
    });
  }

  Future<bool> _checkIosNotificationPermissionEnabled() {
    return _permissionService.isGranted(Permission.notification);
  }

  Future<bool> _checkAndroidNotificationPermissionEnabled(UserName userName) {
    return _permissionService.checkNotificationPermissionEnabled(userName.value);
  }
}