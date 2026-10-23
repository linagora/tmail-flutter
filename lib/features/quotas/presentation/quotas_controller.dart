import 'dart:async';

import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/delegation/presentation/bridge/active_account_reader.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/list_quotas_extensions.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class QuotasController extends BaseController with ActiveAccountReader {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  final GetQuotasInteractor _getQuotasInteractor;

  final isBannerEnabled = RxBool(false);

  late Worker accountIdListener;

  StreamSubscription<Either<Failure, Success>>? _quotaRequest;

  QuotasController(this._getQuotasInteractor);

  /// Only the quota of the account shown last may reach the view, so a new request drops the
  /// result of the one still running.
  void _requestQuota(Stream<Either<Failure, Success>> request) {
    _quotaRequest?.cancel();
    _quotaRequest = request.listen(onData, onError: onError, onDone: onDone);
  }

  void _handleGetQuotasSuccess(GetQuotasSuccess success) {
    log('$runtimeType::_handleGetQuotasSuccess: Quotas is ${success.quotas}');
    mailboxDashBoardController.octetsQuota.value = success.quotas.octetsQuota;
    isBannerEnabled.value = true;
  }

  void _initWorker() {
    accountIdListener = everShownAccount(
      mailboxDashBoardController.accountId,
      (_) => reloadQuota(),
    );
  }

  bool get isStorageCapabilitySupported {
    final accountId = activeAccountId;
    final session = mailboxDashBoardController.sessionCurrent;

    if (accountId != null && session != null) {
      return CapabilityIdentifier.jmapQuota.isSupported(session, accountId);
    } else {
      return false;
    }
  }

  void reloadQuota() {
    if (isStorageCapabilitySupported) {
      _requestQuota(_getQuotasInteractor.execute(activeAccountId!));
    } else {
      _requestQuota(
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
    _quotaRequest?.cancel();
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
      logWarning('$runtimeType::handleFailureViewState');
      mailboxDashBoardController.octetsQuota.value = null;
      isBannerEnabled.value = true;
    } else {
      super.handleFailureViewState(failure);
    }
  }

  void closeBanner() {
    isBannerEnabled.value = false;
  }
}
