import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/utils/app_logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:model/extensions/email_address_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/email_address_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/model/verification/empty_name_validator.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/state/verify_name_view_state.dart';
import 'package:tmail_ui_user/features/mailbox_creator/domain/usecases/verify_name_interactor.dart';
import 'package:tmail_ui_user/features/mailbox_creator/presentation/extensions/validator_failure_extension.dart';
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
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/tmail_forward_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/forward/controller/forward_recipient_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ForwardController extends BaseController {

  final VerifyNameInteractor _verifyNameInteractor;

  GetForwardInteractor? _getForwardInteractor;
  DeleteRecipientInForwardingInteractor? _deleteRecipientInForwardingInteractor;
  AddRecipientsInForwardingInteractor? _addRecipientsInForwardingInteractor;
  EditLocalCopyInForwardingInteractor? _editLocalCopyInForwardingInteractor;

  final accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final _imagePaths = Get.find<ImagePaths>();
  final _appToast = Get.find<AppToast>();

  final selectionMode = Rx<SelectMode>(SelectMode.INACTIVE);
  final listRecipientForward = RxList<RecipientForward>();
  final currentForward = Rxn<TMailForward>();
  final errorRecipientInputText = RxnString();

  bool get currentForwardLocalCopyState => currentForward.value?.localCopy ?? false;

  late ForwardRecipientController recipientController;

  ForwardController(this._verifyNameInteractor) {
    recipientController = ForwardRecipientController(
      accountId: accountDashBoardController.accountId.value,
      session: accountDashBoardController.sessionCurrent.value);
  }

  @override
  void onInit() {
    super.onInit();
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
  void onDone() {
    viewState.value.fold(
        (failure) {
          if (failure is DeleteRecipientInForwardingFailure) {
            cancelSelectionMode();
          }
        },
        (success) {
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
        });
  }

  @override
  void onReady() {
    _getForward();
    super.onReady();
  }

  void _getForward() {
    if (_getForwardInteractor != null) {
      consumeState(_getForwardInteractor!.execute(accountDashBoardController.accountId.value!));
    }
  }

  void deleteRecipients(BuildContext context, String emailAddress) {
    showConfirmDialogAction(currentContext!,
      title: AppLocalizations.of(context).deleteRecipient,
      AppLocalizations.of(context).messageConfirmationDialogDeleteRecipientForward(emailAddress),
      AppLocalizations.of(currentContext!).remove,
      onConfirmAction: () => _handleDeleteRecipientAction({emailAddress}),
      showAsBottomSheet: true,
      icon: SvgPicture.asset(_imagePaths.icDeleteDialogIdentity, fit: BoxFit.fill),
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
      _appToast.showToastWithIcon(
        currentOverlayContext!,
        message: AppLocalizations.of(currentContext!).toastMessageDeleteRecipientSuccessfully,
        icon: _imagePaths.icSelected,
      );
    }

    currentForward.value = success.forward;
    listRecipientForward.value = currentForward.value!.listRecipientForward;
    selectionMode.value = SelectMode.INACTIVE;
  }

  List<RecipientForward> get listRecipientForwardSelected => listRecipientForward
        .where((recipient) => recipient.selectMode == SelectMode.ACTIVE)
        .toList();

  bool get isAllUnSelected =>
      listRecipientForward.every((recipient) => recipient.selectMode == SelectMode.INACTIVE);

  void selectRecipientForward(RecipientForward recipientForward) {
    if (selectionMode.value == SelectMode.INACTIVE) {
      selectionMode.value = SelectMode.ACTIVE;
    }

    final matchRecipientForward = listRecipientForward.indexOf(recipientForward);
    if (matchRecipientForward >= 0) {
      final newRecipientForward = recipientForward.toggleSelection();
      listRecipientForward[matchRecipientForward] = newRecipientForward;
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
      icon: SvgPicture.asset(_imagePaths.icDeleteDialogIdentity, fit: BoxFit.fill),
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

  void addRecipientAction(BuildContext context) {
    FocusScope.of(context).unfocus();

    final accountId = accountDashBoardController.accountId.value;
    final emailAddressSelected = recipientController.emailAddressSelected;

    updateErrorRecipientInputText(context, emailAddressSelected?.email);

    if (errorRecipientInputText.value != null) {
      return;
    }

    log('ForwardController::addRecipientAction():emailAddressSelected: $emailAddressSelected');
    if (emailAddressSelected != null && accountId != null) {
      _handleAddRecipients(accountId, [emailAddressSelected]);
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
      _appToast.showToastWithIcon(
        currentOverlayContext!,
        message: AppLocalizations.of(currentContext!).toastMessageAddRecipientsSuccessfully,
        icon: _imagePaths.icSelected,
      );
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
      _appToast.showToastWithIcon(
        currentOverlayContext!,
        message: success.forward.localCopy ?
          AppLocalizations.of(currentContext!).toastMessageLocalCopyEnable :
          AppLocalizations.of(currentContext!).toastMessageLocalCopyDisable,
        icon: _imagePaths.icSelected,
      );
    }

    currentForward.value = success.forward;
    listRecipientForward.value = currentForward.value!.listRecipientForward;
  }

  void updateErrorRecipientInputText(BuildContext context, String? emailAddress) {
    errorRecipientInputText.value = _getErrorRecipientInputString(context, emailAddress);
  }

  String? _getErrorRecipientInputString(BuildContext context, String? emailAddress) {
    return _verifyNameInteractor.execute(
      emailAddress,
      [EmptyNameValidator(), EmailAddressValidator()]
    ).fold(
      (failure) {
        if (failure is VerifyNameFailure) {
          return failure.getMessageForwarding(context);
        } else {
          return null;
        }
        },
      (success) => null
    );
  }
}