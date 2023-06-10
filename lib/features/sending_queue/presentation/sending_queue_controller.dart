
import 'package:core/presentation/state/failure.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/email/email_action_type.dart';
import 'package:model/extensions/list_email_content_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/email/presentation/model/composer_arguments.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/network_status_handle/presentation/network_connnection_controller.dart';
import 'package:tmail_ui_user/features/offline_mode/manager/sending_email_cache_manager.dart';
import 'package:tmail_ui_user/features/offline_mode/model/sending_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/extensions/list_sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/extensions/sending_email_extension.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/model/sending_email.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/update_multiple_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/state/update_sending_email_state.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/update_multiple_sending_email_interactor.dart';
import 'package:tmail_ui_user/features/sending_queue/domain/usecases/update_sending_email_interactor.dart';
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
  final UpdateSendingEmailInteractor _updateSendingEmailInteractor;
  final UpdateMultipleSendingEmailInteractor _updateMultipleSendingEmailInteractor;

  final dashboardController = getBinding<MailboxDashBoardController>();
  final _networkConnectionController = getBinding<NetworkConnectionController>();
  final _sendingQueueIsolateManager = getBinding<SendingQueueIsolateManager>();
  final _sendingEmailCacheManager = getBinding<SendingEmailCacheManager>();
  final _imagePaths = getBinding<ImagePaths>();
  final _appToast = getBinding<AppToast>();

  final listSendingEmailController = ScrollController();

  final selectionState = Rx<SelectMode>(SelectMode.INACTIVE);

  SendingQueueController(
    this._deleteMultipleSendingEmailInteractor,
    this._updateSendingEmailInteractor,
    this._updateMultipleSendingEmailInteractor,
  );

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

  void _handleSendingQueueEvent(Object? event) async {
    log('SendingQueueController::_handleSendingQueueEvent():event: $event');
    try {
      if (event is String) {
        final tupleKey = TupleKey.fromString(event);
        final sendingId = tupleKey.parts[0];
        final sendingState = SendingState.values.firstWhereOrNull((state) => state.name == tupleKey.parts[1]);
        log('SendingQueueController::_handleSendingQueueEvent():sendingId: $sendingId | sendingState: $sendingState');
        if (sendingState != null) {
          await _sendingEmailCacheManager?.closeSendingEmailHiveCacheBox();

          switch(sendingState) {
            case SendingState.waiting:
              _updatingSendingStateToRunningAction(sendingId);
              break;
            case SendingState.running:
            case SendingState.success:
              refreshSendingQueue();
              break;
            case SendingState.error:
              await WorkSchedulerController().cancelByUniqueId(sendingId);
              _updatingSendingStateToErrorAction(sendingId);
              break;
          }
        }
      }
    } catch (e) {
      logError('SendingQueueController::_handleSendingQueueEvent(): EXCEPTION: $e');
    }
  }

  void _updatingSendingStateToRunningAction(String sendingId) {
    log('SendingQueueController::_updatingSendingStateToRunningAction():sendingId: $sendingId');
    final matchedSendingEmail = dashboardController!.listSendingEmails.firstWhereOrNull((sendingEmail) => sendingEmail.sendingId == sendingId);
    if (matchedSendingEmail != null) {
      final newSendingEmail = matchedSendingEmail.updatingSendingState(SendingState.running);
      _updateSendingEmailAction(newSendingEmail);
    }
  }

  void _updatingSendingStateToErrorAction(String sendingId) {
    log('SendingQueueController::_updatingSendingStateToErrorAction():sendingId: $sendingId');
    final matchedSendingEmail = dashboardController!.listSendingEmails.firstWhereOrNull((sendingEmail) => sendingEmail.sendingId == sendingId);
    if (matchedSendingEmail != null) {
      final newSendingEmail = matchedSendingEmail.updatingSendingState(SendingState.error);
      _updateSendingEmailAction(newSendingEmail);
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

  bool get isConnectedNetwork => _networkConnectionController?.isNetworkConnectionAvailable() == true;

  void refreshSendingQueue() {
    dashboardController!.getAllSendingEmails();
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
      case SendingEmailActionType.edit:
        if (!isConnectedNetwork) {
          _editSendingEmailAction(listSendingEmails.first);
        }
        break;
      case SendingEmailActionType.create:
        break;
      case SendingEmailActionType.resend:
        _resendSendingEmailAction(listSendingEmails);
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
    disableSelectionMode();

    final accountId = dashboardController!.accountId.value;
    final session = dashboardController!.sessionCurrent;
    if (accountId != null && session != null) {
      consumeState(
        _deleteMultipleSendingEmailInteractor.execute(
          accountId,
          session.username,
          listSendingEmails.sendingIds
        )
      );
    }
  }

  void _handleDeleteSendingEmailSuccess(DeleteMultipleSendingEmailSuccess success) async {
    await Future.wait(success.sendingIds.map(WorkSchedulerController().cancelByUniqueId));

    if (currentContext != null && currentOverlayContext != null) {
      _appToast!.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).messageHaveBeenDeletedSuccessfully);
    }

    refreshSendingQueue();
  }

  void _editSendingEmailAction(SendingEmail sendingEmail) {
    disableSelectionMode();

    final arguments = ComposerArguments(
      emailActionType: EmailActionType.edit,
      presentationEmail: sendingEmail.presentationEmail,
      mailboxRole: dashboardController?.selectedMailbox.value?.role,
      emailContents: sendingEmail.presentationEmail.emailContentList.asHtmlString,
      sendingEmail: sendingEmail
    );

    dashboardController?.goToComposer(arguments);
  }

  void _updateSendingEmailAction(SendingEmail newSendingEmail) {
    final accountId = dashboardController!.accountId.value;
    final session = dashboardController!.sessionCurrent;
    if (accountId != null && session != null) {
      consumeState(_updateSendingEmailInteractor.execute(
        accountId,
        session.username,
        newSendingEmail
      ));
    }
  }

  void _resendSendingEmailAction(List<SendingEmail> listSendingEmails) async {
    disableSelectionMode();

    final accountId = dashboardController!.accountId.value;
    final session = dashboardController!.sessionCurrent;

    if (accountId != null && session != null) {
      consumeState(
        _updateMultipleSendingEmailInteractor.execute(
          accountId,
          session.username,
          listSendingEmails.toSendingStateWaiting()
        )
      );
    }
  }

  void _handleResendSendingEmailSuccess(List<SendingEmail> newListSendingEmails) async {
    await Future.forEach<SendingEmail>(newListSendingEmails, (sendingEmail) async {
      await WorkSchedulerController().cancelByUniqueId(sendingEmail.sendingId);
      dashboardController!.addSendingEmailToSendingQueue(sendingEmail);
    });

    if (currentContext != null && currentOverlayContext != null) {
      _appToast!.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).messagesHaveBeenResent);
    }
    refreshSendingQueue();
  }


  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is DeleteMultipleSendingEmailSuccess) {
      _handleDeleteSendingEmailSuccess(success);
    } else if (success is UpdateSendingEmailSuccess) {
      refreshSendingQueue();
    } else if (success is UpdateMultipleSendingEmailAllSuccess) {
      _handleResendSendingEmailSuccess(success.newSendingEmails);
    } else if (success is UpdateMultipleSendingEmailHasSomeSuccess) {
      _handleResendSendingEmailSuccess(success.newSendingEmails);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is UpdateSendingEmailFailure) {
      refreshSendingQueue();
    }
  }

  @override
  void onClose() {
    listSendingEmailController.dispose();
    _sendingQueueIsolateManager?.release();
    super.onClose();
  }
}