import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/validate_premium_storage_extension.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/list_quotas_extensions.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class QuotasController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  final GetQuotasInteractor _getQuotasInteractor;

  final isBannerEnabled = RxBool(false);

  late Worker accountIdListener;

  QuotasController(this._getQuotasInteractor);

  void _getQuotasAction(AccountId accountId) {
    consumeState(_getQuotasInteractor.execute(accountId));
  }

  void _handleGetQuotasSuccess(GetQuotasSuccess success) {
    log('$runtimeType::_handleGetQuotasSuccess: Quotas is ${success.quotas}');
    mailboxDashBoardController.octetsQuota.value = success.quotas.octetsQuota;
    isBannerEnabled.value = true;
  }

  void _initWorker() {
    accountIdListener = ever(
      mailboxDashBoardController.accountId,
      (_) => reloadQuota(),
    );
  }

  bool get isStorageCapabilitySupported {
    final accountId = mailboxDashBoardController.accountId.value;
    final session = mailboxDashBoardController.sessionCurrent;

    if (accountId != null && session != null) {
      return CapabilityIdentifier.jmapQuota.isSupported(session, accountId);
    } else {
      return false;
    }
  }

  void reloadQuota() {
    if (isStorageCapabilitySupported) {
      _getQuotasAction(mailboxDashBoardController.accountId.value!);
    } else {
      consumeState(
        Stream.value(
          Left(GetQuotasFailure(NotFoundAccountIdException())),
        ),
      );
    }
  }

  @override
  void onInit() {
    _initWorker();
    super.onInit();
  }

  @override
  void onClose() {
    accountIdListener.dispose();
    super.onClose();
  }

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
      logError('$runtimeType::handleFailureViewState');
      mailboxDashBoardController.octetsQuota.value = null;
      isBannerEnabled.value = true;
    } else {
      super.handleFailureViewState(failure);
    }
  }

  bool get isManageMyStorageIsDisabled {
    return !mailboxDashBoardController.validatePremiumIsAvailable() ||
      mailboxDashBoardController.validateUserHasIsAlreadyHighestSubscription();
  }

  void handleManageMyStorage() {
    mailboxDashBoardController.paywallController?.navigateToPaywall();
  }

  void closeBanner() {
    isBannerEnabled.value = false;
  }
}
