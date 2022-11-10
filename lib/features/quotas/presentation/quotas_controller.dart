import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/quotas/data_types.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/features/quotas/presentation/model/quotas_state.dart';

class QuotasController extends BaseController {
  final MailboxDashBoardController mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final GetQuotasInteractor _getQuotasInteractor;
  final usedCapacity = Rx<num>(0);
  final softLimitCapacity = Rx<num>(0);
  final warningLimitCapacity = Rx<num>(0);
  final enableShowQuotas = false.obs;
  final quotasState = QuotasState.normal.obs;
  late Worker accountIdWorker;

  double get progressUsedCapacity => softLimitCapacity.value != 0
      ? (usedCapacity.value / softLimitCapacity.value)
      : 0;

  bool get enableShowWarningQuotas =>
      enableShowQuotas.isTrue &&
          (quotasState.value == QuotasState.runningOutOfStorage
              || quotasState.value == QuotasState.runOutOfStorage);

  final ImagePaths imagePaths = Get.find<ImagePaths>();
  final ResponsiveUtils responsiveUtils = Get.find<ResponsiveUtils>();

  QuotasController(this._getQuotasInteractor);

  void _initWorker() {
    accountIdWorker = ever(mailboxDashBoardController.accountId, (accountId) {
      if (accountId is AccountId) {
        _getQuotasAction(accountId);
      }
    });
  }

  void _getQuotasAction(AccountId accountId) {
    enableShowQuotas.value = mailboxDashBoardController.sessionCurrent != null &&
        mailboxDashBoardController.sessionCurrent!.capabilities.containsValue(CapabilityIdentifier.jmapQuota);

    if(enableShowQuotas.isTrue) {
      consumeState(_getQuotasInteractor.execute(mailboxDashBoardController.accountId.value!));
    }
  }

  @override
  void onDone() {
    viewState.value.fold(
      (failure) {
        if (failure is GetQuotasFailure) {
          logError('QuotasController::onDone():[GetQuotasFailure]: ${failure.exception}');
        }
      },
      (success) {
        if (success is GetQuotasSuccess) {
          _handleGetQuotasSuccess(success);
        }
      }
    );
  }

  void _handleGetQuotasSuccess(GetQuotasSuccess success) {
    try {
      final quotas = success.quotas.firstWhere((e) => e.resourceType == ResourceType.octets);
      usedCapacity.value = quotas.used.value;
      warningLimitCapacity.value = quotas.warnLimit?.value ?? 0;
      softLimitCapacity.value = quotas.softLimit?.value ?? 0;
      if(usedCapacity.value >= softLimitCapacity.value) {
        quotasState.value = QuotasState.runOutOfStorage;
      } else if (usedCapacity.value >= warningLimitCapacity.value) {
        quotasState.value = QuotasState.runningOutOfStorage;
      } else {
        quotasState.value = QuotasState.normal;
      }
    } catch (e) {
      logError('QuotasController::_handleGetQuotasSuccess():[NotFoundException]: $e');
    }
  }

  @override
  void onInit() {
    _initWorker();
    super.onInit();
  }

  @override
  void onClose() {
    accountIdWorker.call();
    super.onClose();
  }
}
