import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/paywall/presentation/saas_premium_mixin.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/list_quotas_extensions.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';

class StorageController extends BaseController with SaaSPremiumMixin {
  final dashBoardController = Get.find<ManageAccountDashBoardController>();

  final GetQuotasInteractor _getQuotasInteractor;

  final octetsQuota = Rxn<Quota>();

  StorageController(this._getQuotasInteractor);

  @override
  void onReady() {
    final accountId = dashBoardController.accountId.value;
    if (accountId != null) {
      _getQuotasAction(accountId);
    } else {
      consumeState(
        Stream.value(
          Left(GetQuotasFailure(NotFoundAccountIdException())),
        ),
      );
    }
    super.onReady();
  }

  void _getQuotasAction(AccountId accountId) {
    consumeState(_getQuotasInteractor.execute(accountId));
  }

  void _handleGetQuotasSuccess(GetQuotasSuccess success) {
    octetsQuota.value = success.quotas.octetsQuota;
  }

  bool validatePremiumIsAvailable() {
    final accountId = dashBoardController.accountId.value;
    final session = dashBoardController.sessionCurrent;

    if (accountId == null || session == null) {
      return false;
    }
    return isPremiumAvailable(accountId: accountId, session: session);
  }

  void onUpgradeStorage(BuildContext context) {
    dashBoardController.paywallController?.navigateToPaywall(context);
  }

  bool get isLoading => viewState.value
      .fold((failure) => false, (success) => success is GetQuotasLoading);

  @override
  void handleSuccessViewState(Success success) {
    if (success is GetQuotasSuccess) {
      _handleGetQuotasSuccess(success);
    } else {
      super.handleSuccessViewState(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    if (failure is GetQuotasFailure) {
      octetsQuota.value = null;
    } else {
      super.handleFailureViewState(failure);
    }
  }
}
