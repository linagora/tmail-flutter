import 'package:labels/utils/labels_constants.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

extension HandleSetupLabelVisibilityInSettingExtension
    on ManageAccountDashBoardController {
  bool get isLabelCapabilitySupported {
    if (accountId.value == null || sessionCurrent == null) return false;

    return LabelsConstants.labelsCapability.isSupported(
      sessionCurrent!,
      accountId.value!,
    );
  }
}
