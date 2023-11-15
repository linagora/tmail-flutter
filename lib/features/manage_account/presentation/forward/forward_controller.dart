import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/keyboard_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/add_recipients_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_recipient_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/edit_local_copy_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/add_recipient_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_recipient_in_forwarding_state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/edit_local_copy_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_forward_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/add_recipients_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_recipient_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/edit_local_copy_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_forward_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/action/dashboard_setting_action.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/tmail_forward_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/controller/forward_recipient_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ForwardController extends BaseController {

  GetForwardInteractor? _getForwardInteractor;
  DeleteRecipientInForwardingInteractor? _deleteRecipientInForwardingInteractor;
  AddRecipientsInForwardingInteractor? _addRecipientsInForwardingInteractor;
  EditLocalCopyInForwardingInteractor? _editLocalCopyInForwardingInteractor;

  final accountDashBoardController = Get.find<ManageAccountDashBoardController>();

  final selectionMode = Rx<SelectMode>(SelectMode.INACTIVE);
  final listRecipientForward = RxList<RecipientForward>();
  final currentForward = Rxn<TMailForward>();

  bool get currentForwardLocalCopyState => currentForward.value?.localCopy ?? false;

  late ForwardRecipientController recipientController;

  ForwardController() {
    recipientController = ForwardRecipientController(
      accountId: accountDashBoardController.accountId.value,
      session: accountDashBoardController.sessionCurrent);
  }

  @override
  void onInit() {
    super.onInit();
    registerListenerWorker();
    try {
      _getForwardInteractor = Get.find<GetForwardInteractor>();
      _deleteRecipientInForwardingInteractor = Get.find<DeleteRecipientInForwardingInteractor>();
      _addRecipientsInForwardingInteractor = Get.find<AddRecipientsInForwardingInteractor>();
      _editLocalCopyInForwardingInteractor = Get.find<EditLocalCopyInForwardingInteractor>();
    } catch (e) {
      logError('ForwardController::onInit(): ${e.toString()}');
    }
  }

  @override
  void onClose() {
    recipientController.onClose();
    super.onClose();
  }

  @override
  void onReady() {
    _getForward();
    super.onReady();
  }

  @override
  void handleSuccessViewState(Success success) {
    super.handleSuccessViewState(success);
    if (success is GetForwardSuccess) {
      currentForward.value = success.forward;
      listRecipientForward.value = currentForward.value!.listRecipientForward;
    } else if (success is DeleteRecipientInForwardingSuccess) {
      _handleDeleteRecipientSuccess(success);
    } else if (success is AddRecipientsInForwardingSuccess) {
      _handleAddRecipientsSuccess(success);
    } else if (success is EditLocalCopyInForwardingSuccess) {
      _handleEditLocalCopySuccess(success);
    }
  }

  @override
  void handleFailureViewState(Failure failure) {
    super.handleFailureViewState(failure);
    if (failure is DeleteRecipientInForwardingFailure) {
      cancelSelectionMode();
    }
  }

  void _getForward() {
    if (_getForwardInteractor != null) {
      consumeState(_getForwardInteractor!.execute(accountDashBoardController.accountId.value!));
    }
  }

  void deleteRecipients(BuildContext context, String emailAddress) {
    showConfirmDialogAction(context,
      title: AppLocalizations.of(context).deleteRecipient,
      AppLocalizations.of(context).messageConfirmationDialogDeleteRecipientForward(emailAddress),
      AppLocalizations.of(context).remove,
      onConfirmAction: () => _handleDeleteRecipientAction({emailAddress}),
      showAsBottomSheet: true,
      icon: SvgPicture.asset(imagePaths.icDeleteDialogRecipients, fit: BoxFit.fill),
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColor.colorDeletePermanentlyButton),
      actionStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: Colors.white),
      cancelStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColor.colorTextButton),
      actionButtonColor: AppColor.colorDeletePermanentlyButton,
      cancelButtonColor: AppColor.colorButtonCancelDialog,
    );
  }

  void _handleDeleteRecipientAction(Set<String> listRecipients) {
    final accountId = accountDashBoardController.accountId.value;
    if (accountId != null &&
        currentForward.value != null &&
        _deleteRecipientInForwardingInteractor != null) {
      consumeState(_deleteRecipientInForwardingInteractor!.execute(
          accountId,
          DeleteRecipientInForwardingRequest(
              currentForward: currentForward.value!,
              listRecipientDeleted: listRecipients)));
    }
  }

  void _handleDeleteRecipientSuccess(DeleteRecipientInForwardingSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMessageDeleteRecipientSuccessfully);
    }

    currentForward.value = success.forward;
    listRecipientForward.value = currentForward.value!.listRecipientForward;
    selectionMode.value = SelectMode.INACTIVE;
  }

  List<RecipientForward> get listRecipientForwardSelected =>
    listRecipientForward
      .where((recipient) => recipient.selectMode == SelectMode.ACTIVE)
      .toList();

  bool get isAllUnSelected =>
    listRecipientForward.every((recipient) => recipient.selectMode == SelectMode.INACTIVE);

  bool get isAllSelected =>
    listRecipientForward.every((recipient) => recipient.selectMode == SelectMode.ACTIVE);

  void selectRecipientForward(RecipientForward recipientForward) {
    if (selectionMode.value == SelectMode.INACTIVE) {
      selectionMode.value = SelectMode.ACTIVE;
    }

    final matchedRecipientForward = listRecipientForward.indexOf(recipientForward);
    if (matchedRecipientForward >= 0) {
      final newRecipientForward = recipientForward.toggleSelection();
      listRecipientForward[matchedRecipientForward] = newRecipientForward;
      listRecipientForward.refresh();
    }

    if (isAllUnSelected) {
      selectionMode.value = SelectMode.INACTIVE;
    }
  }

  void cancelSelectionMode() {
    selectionMode.value = SelectMode.INACTIVE;
    listRecipientForward.value = listRecipientForward
      .map((recipient) => recipient.cancelSelection())
      .toList();
  }

  void deleteMultipleRecipients(BuildContext context, Set<String> listEmailAddress) {
    showConfirmDialogAction(currentContext!,
      title: AppLocalizations.of(context).deleteRecipient,
      AppLocalizations.of(context).messageConfirmationDialogDeleteAllRecipientForward,
      AppLocalizations.of(currentContext!).remove,
      onConfirmAction: () => _handleDeleteRecipientAction(listEmailAddress),
      showAsBottomSheet: true,
      icon: SvgPicture.asset(imagePaths.icDeleteDialogRecipients, fit: BoxFit.fill),
      titleStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColor.colorDeletePermanentlyButton),
      actionStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: Colors.white),
      cancelStyle: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w500,
        color: AppColor.colorTextButton),
      actionButtonColor: AppColor.colorDeletePermanentlyButton,
      cancelButtonColor: AppColor.colorButtonCancelDialog,
    );
  }

  void selectAllRecipientForward() {
    if (selectionMode.value == SelectMode.INACTIVE) {
      selectionMode.value = SelectMode.ACTIVE;
    }

    listRecipientForward.value = listRecipientForward
        .map((recipient) => recipient.enableSelection())
        .toList();
  }

  void addRecipientAction(BuildContext context, List<EmailAddress> listRecipientsSelected) {
    KeyboardUtils.hideKeyboard(context);

    final accountId = accountDashBoardController.accountId.value;
    if (accountId != null) {
      _handleAddRecipients(accountId, listRecipientsSelected);
    }
  }

  void _handleAddRecipients(AccountId accountId, List<EmailAddress> listEmailAddress) {
    final listRecipients = listEmailAddress.map((e) => e.emailAddress).toSet();
    if (currentForward.value != null && _addRecipientsInForwardingInteractor != null) {
      consumeState(_addRecipientsInForwardingInteractor!.execute(
          accountId,
          AddRecipientInForwardingRequest(
              currentForward: currentForward.value!,
              listRecipientAdded: listRecipients)));
    }
  }

  void _handleAddRecipientsSuccess(AddRecipientsInForwardingSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        AppLocalizations.of(currentContext!).toastMessageAddRecipientsSuccessfully);
    }

    currentForward.value = success.forward;
    listRecipientForward.value = currentForward.value!.listRecipientForward;

    recipientController.clearAll();
  }

  void handleEditLocalCopy() {
    final accountId = accountDashBoardController.accountId.value;
    if (accountId != null &&
        currentForward.value != null &&
        _editLocalCopyInForwardingInteractor != null) {
      consumeState(_editLocalCopyInForwardingInteractor!.execute(
          accountId,
          EditLocalCopyInForwardingRequest(
              currentForward: currentForward.value!,
              keepLocalCopy: !currentForward.value!.localCopy)));
    }
  }

  void _handleEditLocalCopySuccess(EditLocalCopyInForwardingSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      appToast.showToastSuccessMessage(
        currentOverlayContext!,
        success.forward.localCopy
          ? AppLocalizations.of(currentContext!).toastMessageLocalCopyEnable
          : AppLocalizations.of(currentContext!).toastMessageLocalCopyDisable);
    }

    currentForward.value = success.forward;
    listRecipientForward.value = currentForward.value!.listRecipientForward;
  }

  void registerListenerWorker() {
    ever(
      accountDashBoardController.dashboardSettingAction,
      (action) {
        if (action is ClearAllInputForwarding) {
          cancelSelectionMode();
          recipientController.clearAll();
        }
      }
    );
  }

  void handleExceptionCallback(BuildContext context, bool isListEmailEmpty) {
    if (isListEmailEmpty) {
      appToast.showToastErrorMessage(
        context,
        AppLocalizations.of(context).emptyListEmailForward);
    } else {
      appToast.showToastErrorMessage(
        context,
        AppLocalizations.of(context).incorrectEmailFormat);
    }
  }
}