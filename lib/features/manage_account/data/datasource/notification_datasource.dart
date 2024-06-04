import 'package:jmap_dart_client/jmap/core/user_name.dart';

abstract class NotificationDataSource {
  Future<bool> getNotificationSetting(UserName userName);

  Future<void> toggleNotificationSetting();
}