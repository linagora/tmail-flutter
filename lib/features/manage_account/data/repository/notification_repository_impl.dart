import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:tmail_ui_user/features/manage_account/data/datasource/notification_datasource.dart';
import 'package:tmail_ui_user/features/manage_account/domain/repository/notification_repository.dart';

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationDataSource _notificationDataSource;

  NotificationRepositoryImpl(this._notificationDataSource);
  
  @override
  Future<bool> getNotificationSetting(UserName userName) {
    return _notificationDataSource.getNotificationSetting(userName);
  }
  
  @override
  Future<void> toggleNotificationSetting() {
    return _notificationDataSource.toggleNotificationSetting();
  }
}