import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

extension ValidateSettingCapabilitySupportedExtension
    on ManageAccountDashBoardController {
  bool get isStorageCapabilitySupported {
    if (accountId.value != null && sessionCurrent != null) {
      return CapabilityIdentifier.jmapQuota.isSupported(
        sessionCurrent!,
        accountId.value!,
      );
    } else {
      return false;
    }
  }
}
