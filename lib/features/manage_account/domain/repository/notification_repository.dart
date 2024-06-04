import 'package:jmap_dart_client/jmap/core/user_name.dart';

abstract class NotificationRepository {
  Future<bool> getNotificationSetting(UserName userName);

  Future<void> toggleNotificationSetting();
}