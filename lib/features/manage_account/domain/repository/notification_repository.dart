abstract class NotificationRepository {
  Future<bool> getAppNotificationSetting();

  Future<void> toggleAppNotificationSetting(bool isEnabled);

  Future<bool> attemptToggleSystemNotificationSetting();
}