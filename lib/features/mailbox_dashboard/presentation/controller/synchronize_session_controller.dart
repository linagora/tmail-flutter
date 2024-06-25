import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/consume_view_state_ui_controller.dart';
import 'package:tmail_ui_user/features/base/state/base_ui_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/synchronize_latest_session_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/synchronize_latest_session_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SynchronizeSessionController extends ConsumeViewStateUIController {

  final SynchronizeLatestSessionInteractor _synchronizeLatestSessionInteractor;

  SynchronizeSessionController(this._synchronizeLatestSessionInteractor);

  @override
  void handleSuccessViewState(Success success) {
    log('SynchronizeSessionController::handleSuccessViewState: ${success.runtimeType}');
    if (success is SynchronizeLatestSessionSuccess) {
      _handleSynchronizeSessionSuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    logError('SynchronizeSessionController::handleFailureViewState: ${failure.runtimeType}');
  }

  @override
  void onClose() {
    log('SynchronizeSessionController::onClose:');
    dispatchState(Right(UIClosedState()));
    super.onClose();
  }

  void synchronizeSession() {
    consumeState(_synchronizeLatestSessionInteractor.execute());
  }

  void _handleSynchronizeSessionSuccess(SynchronizeLatestSessionSuccess success) {
    final dashboardController = getBinding<MailboxDashBoardController>();
    if (dashboardController != null) {
      final accountId = success.session.jmapPersonalAccount.accountId;

      dashboardController.sessionCurrent = success.session;
      dashboardController.accountId.value = accountId;

      dashboardController.injectDataBindings(
        session: success.session,
        accountId: accountId);

      dashboardController.fetchingData(
        accountId: accountId,
        session: success.session,
        userName: success.session.username);
    }
  }
}
