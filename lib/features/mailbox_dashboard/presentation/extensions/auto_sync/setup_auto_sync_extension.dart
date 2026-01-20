import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/preferences_setting_manager.dart';
import 'package:tmail_ui_user/features/push_notification/presentation/controller/web_socket_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension SetupAutoSyncExtension on MailboxDashBoardController {
  static final _isAutoSyncEnabled = true.obs;

  RxBool get isAutoSyncEnabled => _isAutoSyncEnabled;

  /// Get the actual WebSocket connection state for UI display
  Rx<WebSocketConnectionState> get webSocketConnectionState =>
      WebSocketController.instance.connectionState;

  /// Whether auto-sync is actually working (enabled AND connected)
  bool get isAutoSyncActive =>
      _isAutoSyncEnabled.value &&
      WebSocketController.instance.connectionState.value ==
          WebSocketConnectionState.connected;

  Future<void> loadAutoSyncConfig() async {
    try {
      final preferencesManager = getBinding<PreferencesSettingManager>();
      if (preferencesManager != null) {
        final config = await preferencesManager.getAutoSyncConfig();
        _isAutoSyncEnabled.value = config.isEnabled;
        log('SetupAutoSyncExtension::loadAutoSyncConfig: isEnabled = ${config.isEnabled}');
        _applyAutoSyncSetting(config.isEnabled);
      }
    } catch (e) {
      log('SetupAutoSyncExtension::loadAutoSyncConfig: error = $e');
      _isAutoSyncEnabled.value = true;
      _applyAutoSyncSetting(true);
    }
  }

  Future<void> toggleAutoSync() async {
    final newValue = !_isAutoSyncEnabled.value;
    _isAutoSyncEnabled.value = newValue;

    try {
      final preferencesManager = getBinding<PreferencesSettingManager>();
      if (preferencesManager != null) {
        await preferencesManager.updateAutoSync(newValue);
        log('SetupAutoSyncExtension::toggleAutoSync: saved isEnabled = $newValue');
      }
    } catch (e) {
      log('SetupAutoSyncExtension::toggleAutoSync: error saving = $e');
    }

    _applyAutoSyncSetting(newValue);
  }

  void _applyAutoSyncSetting(bool isEnabled) {
    if (isEnabled) {
      // Re-connect WebSocket if it was disconnected
      log('SetupAutoSyncExtension::_applyAutoSyncSetting: enabling auto-sync');
      WebSocketController.instance.reconnect();
    } else {
      // Disconnect WebSocket to disable auto-sync
      log('SetupAutoSyncExtension::_applyAutoSyncSetting: disabling auto-sync');
      WebSocketController.instance.disconnect();
    }
  }
}
