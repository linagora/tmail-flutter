import 'package:labels/utils/labels_constants.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_label_visibility_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_label_visibility_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleSetupLabelVisibilityInSettingExtension
    on ManageAccountDashBoardController {
  bool get isLabelCapabilitySupported {
    if (accountId.value == null || sessionCurrent == null) return false;

    return LabelsConstants.labelsCapability.isSupported(
      sessionCurrent!,
      accountId.value!,
    );
  }

  void enableLabelVisibility() {
    isLabelVisibilityEnabled.value = true;

    saveLabelVisibilityInteractor = getBinding<SaveLabelVisibilityInteractor>();
    if (saveLabelVisibilityInteractor != null) {
      consumeState(saveLabelVisibilityInteractor!.execute());
    }

    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).theLabelFeatureIsNowAvailable,
      );
    }
  }

  void setUpLabelVisibility() {
    getLabelVisibilityInteractor = getBinding<GetLabelVisibilityInteractor>();
    if (getLabelVisibilityInteractor != null) {
      consumeState(getLabelVisibilityInteractor!.execute());
    }
  }

  void handleGetLabelVisibilitySuccess(bool visible) {
    isLabelVisibilityEnabled.value = visible;
  }
}
