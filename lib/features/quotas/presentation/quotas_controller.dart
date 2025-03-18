import 'package:core/presentation/state/success.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/quotas/quota.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/list_quotas_extensions.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class QuotasController extends BaseController {

  final mailboxDashBoardController = Get.find<MailboxDashBoardController>();

  final GetQuotasInteractor _getQuotasInteractor;

  final octetsQuota = Rxn<Quota>();

  late Worker accountIdListener;

  QuotasController(this._getQuotasInteractor);

  void _getQuotasAction(AccountId accountId) {
    consumeState(_getQuotasInteractor.execute(accountId));
  }

  void _handleGetQuotasSuccess(GetQuotasSuccess success) {
    octetsQuota.value = success.quotas.octetsQuota;
  }

  void _initWorker() {
    accountIdListener = ever(mailboxDashBoardController.accountId, (accountId) {
      final session = mailboxDashBoardController.sessionCurrent;
      if (accountId is AccountId &&
          session != null &&
          CapabilityIdentifier.jmapQuota.isSupported(session, accountId)
      ) {
        _getQuotasAction(accountId);
      }
    });
  }

  void reloadQuota() {
    if (mailboxDashBoardController.accountId.value == null) return;
    
    _getQuotasAction(mailboxDashBoardController.accountId.value!);
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
    super.handleSuccessViewState(success);
    if (success is GetQuotasSuccess) {
      _handleGetQuotasSuccess(success);
    }
  }
}
