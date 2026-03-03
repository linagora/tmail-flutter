import 'package:core/utils/app_logger.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';

extension HandleLogicLabelExtension on MailboxDashBoardController {
  bool get isLabelCapabilitySupported {
    final accountId = this.accountId.value;
    final session = sessionCurrent;

    if (accountId == null || session == null) return false;

    return labelController.isLabelCapabilitySupported(session, accountId);
  }

  bool get isLabelAvailable {
    return labelController.isLabelSettingEnabled.isTrue &&
        isLabelCapabilitySupported;
  }

  void registerLabelReactiveObxListener() {
    workerObxVariables.add(
      ever(
        labelController.isLabelSettingEnabled,
        _onLabelSettingEnabledChanged,
      ),
    );
  }

  void _onLabelSettingEnabledChanged(bool isEnabled) {
    log('$runtimeType::_onLabelSettingEnabledChanged: isEnabled is $isEnabled');
    final isLabelAvailable = isEnabled && isLabelCapabilitySupported;
    injectWebSocket(
      session: sessionCurrent,
      accountId: accountId.value,
      isLabelAvailable: isLabelAvailable,
    );
  }
}
