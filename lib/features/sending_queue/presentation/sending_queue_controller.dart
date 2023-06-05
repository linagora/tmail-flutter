
import 'package:core/utils/app_logger.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/composer/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/offline_mode/scheduler/worker_state.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/utils/sending_queue_isolate_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/controller/work_scheduler_controller.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/delete_multiple_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/delete_multiple_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/extensions/list_sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/presentation/model/sending_email_action_type.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class SendingQueueController extends BaseController with MessageDialogActionMixin {

  final DeleteMultipleSendingEmailInteractor _deleteMultipleSendingEmailInteractor;

  final dashboardController = getBinding<MailboxDashBoardController>();
  final _sendingQueueIsolateManager = getBinding<SendingQueueIsolateManager>();
  final _imagePaths = getBinding<ImagePaths>();
  final _appToast = getBinding<AppToast>();

  final listSendingEmailController = ScrollController();

  final selectionState = Rx<SelectMode>(SelectMode.INACTIVE);

  SendingQueueController(this._deleteMultipleSendingEmailInteractor);

  @override
  void onInit() {
    super.onInit();
    _sendingQueueIsolateManager?.initial(
      onData: _handleSendingQueueEvent,
      onError: (error, stackTrace) {
        logError('SendingQueueController::onInit():onError:error: $error | stackTrace: $stackTrace');
      }
    );
  }

  void _handleSendingQueueEvent(Object? event) {
    log('SendingQueueController::_handleSendingQueueEvent():event: $event');
    if (event is String) {
      final workState = WorkerState.values.firstWhereOrNull((state) => state.name == event);
      log('SendingQueueController::_handleSendingQueueEvent():workState: $workState');
      if (workState != null) {
        _refreshSendingQueue(needToReopen: true);
      }
    }
  }

  void handleOnLongPressAction(SendingEmail sendingEmail) {
    final newListSendingEmail = dashboardController!.listSendingEmails.toggleSelection(sendingEmailSelected: sendingEmail);
    dashboardController!.listSendingEmails.value = newListSendingEmail;

    selectionState.value = newListSendingEmail.isAllUnSelected()
      ? SelectMode.INACTIVE
      : SelectMode.ACTIVE;
  }

  void toggleSelectionSendingEmail(SendingEmail sendingEmail) {
    final newListSendingEmail = dashboardController!.listSendingEmails.toggleSelection(sendingEmailSelected: sendingEmail);
    dashboardController!.listSendingEmails.value = newListSendingEmail;

    selectionState.value = newListSendingEmail.isAllUnSelected()
      ? SelectMode.INACTIVE
      : SelectMode.ACTIVE;
  }

  bool get isAllUnSelected => dashboardController!.listSendingEmails.isAllUnSelected();

  void _refreshSendingQueue({bool needToReopen = false}) {
    dashboardController!.getAllSendingEmails(needToReopen: needToReopen);
  }

  void openMailboxMenu() {
    dashboardController!.openMailboxMenuDrawer();
  }

  void disableSelectionMode() {
    final newListSendingEmail = dashboardController!.listSendingEmails.unAllSelected();
    dashboardController!.listSendingEmails.value = newListSendingEmail;
    selectionState.value = SelectMode.INACTIVE;
  }

  void handleSendingEmailActionType(
    BuildContext context,
    SendingEmailActionType actionType,
    List<SendingEmail> listSendingEmails
  ) {
    switch(actionType) {
      case SendingEmailActionType.delete:
        _deleteSendingEmailAction(context, listSendingEmails);
        break;
    }
  }

  void _deleteSendingEmailAction(BuildContext context, List<SendingEmail> listSendingEmails) {
    showConfirmDialogAction(
      context,
      AppLocalizations.of(context).messageDialogDeleteSendingEmail,
      AppLocalizations.of(currentContext!).delete,
      title: AppLocalizations.of(currentContext!).deleteOfflineEmail,
      icon: SvgPicture.asset(_imagePaths!.icDeleteDialogRecipients),
      alignCenter: true,
      messageStyle: const TextStyle(
        color: AppColor.colorTitleSendingItem,
        fontSize: 15,
        fontWeight: FontWeight.normal
      ),
      titleStyle: const TextStyle(
        color: AppColor.colorDeletePermanentlyButton,
        fontSize: 20,
        fontWeight: FontWeight.bold
      ),
      actionButtonColor: AppColor.colorDeletePermanentlyButton,
      actionStyle: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w500
      ),
      cancelStyle: const TextStyle(
        color: AppColor.colorDeletePermanentlyButton,
        fontSize: 17,
        fontWeight: FontWeight.w500
      ),
      onConfirmAction: () => _handleDeleteSendingEmail(listSendingEmails),
    );
  }

  void _handleDeleteSendingEmail(List<SendingEmail> listSendingEmails) async {
    final accountId = dashboardController!.accountId.value;
    final session = dashboardController!.sessionCurrent;

    if (accountId != null && session != null) {
      final sendingIds = listSendingEmails.map((sendingEmail) => sendingEmail.sendingId).toSet().toList();

      await Future.wait(
        sendingIds.map((sendingId) => WorkSchedulerController().cancelByUniqueId(sendingId)),
        eagerError: true
      );

      consumeState(_deleteMultipleSendingEmailInteractor.execute(accountId, session.username, sendingIds));
    }
  }

  void _handleDeleteSendingEmailSuccess() {
    if (currentContext != null && currentOverlayContext != null) {
      selectionState.value = SelectMode.INACTIVE;

      _appToast!.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).deleteSomeOfflineEmailSuccessfully
      );

      _refreshSendingQueue();
    }
  }

  void _handleDeleteSendingEmailFailure() {
    selectionState.value = SelectMode.INACTIVE;
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is DeleteMultipleSendingEmailAllSuccess ||
        success is DeleteMultipleSendingEmailHasSomeSuccess) {
      _handleDeleteSendingEmailSuccess();
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is DeleteMultipleSendingEmailAllFailure ||
        failure is DeleteMultipleSendingEmailFailure) {
      _handleDeleteSendingEmailFailure();
    }
  }

  @override
  void onClose() {
    listSendingEmailController.dispose();
    _sendingQueueIsolateManager?.release();
    super.onClose();
  }
}