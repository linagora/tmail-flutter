abstract class NotificationDataSource {
  Future<bool> getAppNotificationSetting();

  Future<void> toggleAppNotificationSetting(bool isEnabled);

  Future<bool> attemptToggleSystemNotificationSetting();
}