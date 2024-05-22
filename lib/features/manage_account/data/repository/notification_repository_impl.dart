import 'package:tmail_ui_user/features/manage_account/data/datasource/notification_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource _notificationDataSource;

  NotificationRepositoryImpl(this._notificationDataSource);
  
  @override
  Future<bool> getAppNotificationSetting() {
    return _notificationDataSource.getAppNotificationSetting();
  }
  
  @override
  Future<void> toggleAppNotificationSetting(bool isEnabled) {
    return _notificationDataSource.toggleAppNotificationSetting(isEnabled);
  }
  
  @override
  Future<bool> attemptToggleSystemNotificationSetting() {
    return _notificationDataSource.attemptToggleSystemNotificationSetting();
  }
}