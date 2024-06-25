import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/utils/app_logger.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/extensions/session_extension.dart';
import 'package:tmail_ui_user/features/base/consume_view_state_ui_controller.dart';
import 'package:tmail_ui_user/features/base/state/base_ui_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/state/synchronize_latest_session_state.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/usecases/synchronize_latest_session_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SynchronizeSessionController extends ConsumeViewStateUIController {

  final SynchronizeLatestSessionInteractor _synchronizeLatestSessionInteractor;

  final _imagePath = Get.find<ImagePaths>();

  bool isResynchronized = false;
  bool isShowingWarningDialogSessionExpired = false;
  bool isShowingWarningDialogResynchronizeSessionFailure = false;

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
    if (failure is SynchronizeLatestSessionFailure) {
      _handleSynchronizeSessionFailure(failure);
    }
  }

  @override
  void onClose() {
    log('SynchronizeSessionController::onClose:');
    isShowingWarningDialogSessionExpired = false;
    isShowingWarningDialogResynchronizeSessionFailure = false;
    isResynchronized = false;
    dispatchState(Right(UIClosedState()));
    super.onClose();
  }

  void synchronizeSession() {
    consumeState(_synchronizeLatestSessionInteractor.execute());
  }

  void resynchronizeSession() {
    isShowingWarningDialogSessionExpired = false;
    isResynchronized = true;
    synchronizeSession();
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

  void _handleSynchronizeSessionFailure(SynchronizeLatestSessionFailure failure) {
    if (currentContext == null) {
      logError('SynchronizeSessionController::_handleSynchronizeSessionFailure: CONTEXT IS NULL');
      return;
    }

    if (!isResynchronized) {
      _showWarningDialogSessionExpired(currentContext!);
    } else {
      _showWarningDialogResynchronizeSessionFailure(currentContext!);
    }
  }

  Future<void> _showWarningDialogSessionExpired(BuildContext context) async {
    log('SynchronizeSessionController::_showWarningDialogSessionExpired:');
    isShowingWarningDialogSessionExpired = true;

    await showConfirmDialogAction(
      context,
      AppLocalizations.of(context).warningMessageWhenSynchronizeSessionFailure,
      AppLocalizations.of(context).resynchronize,
      cancelTitle: AppLocalizations.of(context).exitAndReLogin,
      alignCenter: true,
      outsideDismissible: false,
      autoPerformPopBack: false,
      isArrangeActionButtonsVertical: true,
      onConfirmAction: () {
        popBack();
        resynchronizeSession();
      },
      onCancelAction: () {
        popBack();
        exitAndReLoginAction();
      },
      messageStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 14,
        color: AppColor.colorTextBody
      ),
      actionStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 17,
        color: Colors.white
      ),
      cancelStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 17,
        color: Colors.black
      ),
      marginIcon: const EdgeInsets.only(top: 16),
      icon: SvgPicture.asset(
        _imagePath.icQuotasWarning,
        width: 40,
        height: 40,
        colorFilter: AppColor.colorBackgroundQuotasWarning.asFilter(),
      )
    );
  }

  Future<void> _showWarningDialogResynchronizeSessionFailure(BuildContext context) async {
    log('SynchronizeSessionController::_showWarningDialogResynchronizeSessionFailure:');
    isShowingWarningDialogResynchronizeSessionFailure = true;

    await showConfirmDialogAction(
      context,
      AppLocalizations.of(context).warningMessageWhenResynchronizeSessionFailure,
      AppLocalizations.of(context).exitAndReLogin,
      alignCenter: true,
      outsideDismissible: false,
      autoPerformPopBack: false,
      isArrangeActionButtonsVertical: true,
      hasCancelButton: false,
      onConfirmAction: () {
        popBack();
        exitAndReLoginAction();
      },
      messageStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 14,
        color: AppColor.colorTextBody
      ),
      actionStyle: Theme.of(context).textTheme.labelMedium?.copyWith(
        fontSize: 17,
        color: Colors.white
      ),
      marginIcon: const EdgeInsets.only(top: 16),
      icon: SvgPicture.asset(
        _imagePath.icQuotasWarning,
        width: 40,
        height: 40,
        colorFilter: AppColor.colorBackgroundQuotasWarning.asFilter(),
      )
    );
  }

  void exitAndReLoginAction() {
    log('SynchronizeSessionController::exitAndReLoginAction:');
    isShowingWarningDialogSessionExpired = false;
    isShowingWarningDialogResynchronizeSessionFailure = false;
    isResynchronized = false;
    final dashboardController = getBinding<MailboxDashBoardController>();
    if (dashboardController != null) {
      dashboardController.clearDataAndGoToLoginPage();
    }
  }
}
