import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/paywall/domain/model/paywall_url_pattern.dart';
import 'package:tmail_ui_user/features/paywall/domain/state/get_paywall_url_state.dart';
import 'package:tmail_ui_user/features/paywall/domain/usecases/get_paywall_url_interactor.dart';
import 'package:tmail_ui_user/features/paywall/presentation/paywall_controller.dart';
import 'package:tmail_ui_user/features/paywall/presentation/saas_premium_mixin.dart';

class StorageController extends BaseController with SaaSPremiumMixin {
  final ManageAccountDashBoardController dashBoardController;
  final GetPaywallUrlInteractor _getPaywallUrlInteractor;

  final _ecosystemPaywallUrlPattern = Rxn<PaywallUrlPattern>();
  StreamSubscription<Either<Failure, Success>>? _paywallUrlSubscription;

  StorageController({
    required this.dashBoardController,
    required GetPaywallUrlInteractor getPaywallUrlInteractor,
  }) : _getPaywallUrlInteractor = getPaywallUrlInteractor;

  @override
  void onInit() {
    super.onInit();
    if (!PlatformInfo.isWeb) return;

    _loadEcosystemPaywallUrl();
  }

  void _loadEcosystemPaywallUrl() {
    if (!validatePremiumIsAvailable()) return;

    final jmapUrl = dynamicUrlInterceptors.jmapUrl;
    if (jmapUrl == null) return;

    _paywallUrlSubscription = _getPaywallUrlInteractor.execute(jmapUrl).listen(
      _handlePaywallUrlState,
      onError: (Object error, StackTrace stackTrace) {
        if (isClosed) return;
        _ecosystemPaywallUrlPattern.value = null;
        onError(error, stackTrace);
      },
    );
  }

  void _handlePaywallUrlState(Either<Failure, Success> state) {
    if (isClosed) return;

    state.fold(
      (failure) {
        _ecosystemPaywallUrlPattern.value = null;
        onDataFailureViewState(failure);
      },
      (success) {
        if (success is GetPaywallUrlSuccess) {
          _ecosystemPaywallUrlPattern.value = success.paywallUrlPattern;
        }
      },
    );
  }

  bool validatePremiumIsAvailable() {
    final accountId = dashBoardController.accountId.value;
    final session = dashBoardController.sessionCurrent;

    if (accountId == null || session == null) {
      return false;
    }
    return isPremiumAvailable(accountId: accountId, session: session);
  }

  bool validateUserHasIsAlreadyHighestSubscription() {
    final accountId = dashBoardController.accountId.value;
    final session = dashBoardController.sessionCurrent;

    if (accountId == null || session == null) {
      return false;
    }

    return isAlreadyHighestSubscription(accountId: accountId, session: session);
  }

  bool isUpgradeStorageDisabled({String? workplaceFqdn}) {
    if (!validatePremiumIsAvailable()) return true;
    return !(dashBoardController.paywallController?.canNavigateToPaywall(
      workplaceFqdn: workplaceFqdn,
      ecosystemPaywallUrlPattern: _ecosystemPaywallUrlPattern.value,
    ) ?? false);
  }

  void onUpgradeStorage({String? workplaceFqdn}) {
    if (PlatformInfo.isWeb &&
        isUpgradeStorageDisabled(workplaceFqdn: workplaceFqdn)) {
      return;
    }

    dashBoardController.paywallController?.navigateToPaywall(
      workplaceFqdn: workplaceFqdn,
      ecosystemPaywallUrlPattern: _ecosystemPaywallUrlPattern.value,
    );
  }

  @override
  void onClose() {
    unawaited(_paywallUrlSubscription?.cancel());
    _paywallUrlSubscription = null;
    super.onClose();
  }
}
