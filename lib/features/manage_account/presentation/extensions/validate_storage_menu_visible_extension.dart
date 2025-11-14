import 'package:dartz/dartz.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/quotas/domain/exceptions/quotas_exception.dart';
import 'package:tmail_ui_user/features/quotas/domain/extensions/list_quotas_extensions.dart';
import 'package:tmail_ui_user/features/quotas/domain/state/get_quotas_state.dart';
import 'package:tmail_ui_user/features/quotas/domain/use_case/get_quotas_interactor.dart';
import 'package:tmail_ui_user/features/quotas/presentation/quotas_interactor_bindings.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension ValidateStorageMenuVisibleExtension
    on ManageAccountDashBoardController {
  void injectQuotaBindings() {
    QuotasInteractorBindings().dependencies();
  }

  void getQuotas(AccountId? accountId) {
    if (accountId == null) {
      consumeState(
        Stream.value(Left(GetQuotasFailure(NotFoundAccountIdException))),
      );
      return;
    }

    getQuotasInteractor = getBinding<GetQuotasInteractor>();
    if (getQuotasInteractor == null) {
      consumeState(
        Stream.value(Left(GetQuotasFailure(QuotasNotSupportedException))),
      );
      return;
    }

    consumeState(getQuotasInteractor!.execute(accountId));
  }

  void handleGetQuotasSuccess(GetQuotasSuccess success) {
    octetsQuota.value = success.quotas.octetsQuota;
  }

  void handleGetQuotasFailure() {
    octetsQuota.value = null;
  }
}
