import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/capability/capability_identifier.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/quotas/data_types.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/features/quotas/presentation/model/quotas_state.dart';
import 'package:tmail_ui_user/main/error/capability_validator.dart';

class QuotasController extends BaseController {
  final MailboxDashBoardController mailboxDashBoardController = Get.find<MailboxDashBoardController>();
  final GetQuotasInteractor _getQuotasInteractor;
  final usedCapacity = Rx<num>(0);
  final limitCapacity = Rx<num>(0);
  final warningLimitCapacity = Rx<num>(0);
  final enableShowQuotas = false.obs;
  final quotasState = QuotasState.normal.obs;
  final warningProgressConstant = 0.9;
  late Worker accountIdWorker;

  double get progressUsedCapacity => limitCapacity.value != 0
      ? (usedCapacity.value / limitCapacity.value)
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
      if (accountId is AccountId && mailboxDashBoardController.sessionCurrent!= null) {
        _getQuotasAction(accountId, mailboxDashBoardController.sessionCurrent!);
      }
    });
  }

  void _getQuotasAction(AccountId accountId, Session session) {
    try {
      requireCapability(session, accountId, [CapabilityIdentifier.jmapQuota]);
      consumeState(_getQuotasInteractor.execute(mailboxDashBoardController.accountId.value!));
    } catch (e) {
      logError('QuotasController::_getQuotasAction():$e');
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
      warningLimitCapacity.value = quotas.limit.value * warningProgressConstant;
      limitCapacity.value = quotas.limit.value;
      if(usedCapacity.value >= limitCapacity.value) {
        quotasState.value = QuotasState.runOutOfStorage;
      } else if (usedCapacity.value >= warningLimitCapacity.value) {
        quotasState.value = QuotasState.runningOutOfStorage;
      } else {
        quotasState.value = QuotasState.normal;
      }
      enableShowQuotas.value = true;
    } catch (e) {
      enableShowQuotas.value = false;
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
