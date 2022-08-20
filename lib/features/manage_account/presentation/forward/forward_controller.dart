import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:forward/forward/tmail_forward.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_recipient_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_recipient_in_forwarding_state.dart';
import 'package:jmap_dart_client/jmap/mail/email/email_address.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/mails_forward_creator/presentation/model/mails_forward_creator_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_forward_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_recipient_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_forward_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/tmail_forward_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ForwardController extends BaseController {

  final GetForwardInteractor _getForwardInteractor;
  final DeleteRecipientInForwardingInteractor _deleteRecipientInForwardingInteractor;

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();
  final _appToast = Get.find<AppToast>();

  final selectionMode = Rx<SelectMode>(SelectMode.INACTIVE);
  final listRecipientForward = RxList<RecipientForward>();

  TMailForward? currentForward;

  ForwardController(
    this._getForwardInteractor,
    this._deleteRecipientInForwardingInteractor,
  );

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
            currentForward = success.forward;
            listRecipientForward.value = currentForward!.listRecipientForward;
          } else if (success is DeleteRecipientInForwardingSuccess) {
            _handleDeleteRecipientSuccess(success);
          }
        });
  }

  @override
  void onError(error) {}

  @override
  void onInit() {
    _getForward();
    super.onInit();
  }

  void _getForward() {
    consumeState(_getForwardInteractor.execute(_accountDashBoardController.accountId.value!));
  }

  void deleteRecipients(BuildContext context, String emailAddress) {
    if (_responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context)
            .messageConfirmationDialogDeleteRecipientForward(emailAddress))
        ..onCancelAction(AppLocalizations.of(context).cancel, () =>
            popBack())
        ..onConfirmAction(AppLocalizations.of(context).delete, () =>
            _handleDeleteRecipientAction({emailAddress})))
      .show();
    } else {
      showDialog(
        context: context,
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
        builder: (BuildContext context) =>
          PointerInterceptor(child: (ConfirmDialogBuilder(_imagePaths)
            ..title(AppLocalizations.of(context).deleteRecipient)
            ..content(AppLocalizations.of(context)
                .messageConfirmationDialogDeleteRecipientForward(emailAddress))
            ..addIcon(SvgPicture.asset(_imagePaths.icRemoveDialog,
                fit: BoxFit.fill))
            ..marginIcon(EdgeInsets.zero)
            ..colorConfirmButton(AppColor.colorConfirmActionDialog)
            ..styleTextConfirmButton(const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColor.colorActionDeleteConfirmDialog))
            ..onCloseButtonAction(() => popBack())
            ..onConfirmButtonAction(AppLocalizations.of(context).delete, () =>
                _handleDeleteRecipientAction({emailAddress}))
            ..onCancelButtonAction(AppLocalizations.of(context).cancel, () =>
                popBack()))
          .build()));
    }
  }

  void _handleDeleteRecipientAction(Set<String> listRecipients) {
    popBack();

    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null && currentForward != null) {
      consumeState(_deleteRecipientInForwardingInteractor.execute(
          accountId,
          DeleteRecipientInForwardingRequest(
              currentForward: currentForward!,
              listRecipientDeleted: listRecipients)));
    }
  }

  void _handleDeleteRecipientSuccess(DeleteRecipientInForwardingSuccess success) {
    if (currentOverlayContext != null && currentContext != null) {
      _appToast.showToastWithIcon(
          currentOverlayContext!,
          message: AppLocalizations.of(currentContext!).toastMessageDeleteRecipientSuccessfully,
          icon: _imagePaths.icSelected);
    }

    currentForward = success.forward;
    listRecipientForward.value = currentForward!.listRecipientForward;
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
    if (_responsiveUtils.isMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context).messageConfirmationDialogDeleteAllRecipientForward)
        ..onCancelAction(AppLocalizations.of(context).cancel, () =>
            popBack())
        ..onConfirmAction(AppLocalizations.of(context).delete, () {
          _handleDeleteRecipientAction(listEmailAddress);
        }))
      .show();
    } else {
      showDialog(
        context: context,
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
        builder: (BuildContext context) =>
          PointerInterceptor(child: (ConfirmDialogBuilder(_imagePaths)
            ..title(AppLocalizations.of(context).deleteRecipient)
            ..content(AppLocalizations.of(context).messageConfirmationDialogDeleteAllRecipientForward)
            ..addIcon(SvgPicture.asset(_imagePaths.icRemoveDialog,
                fit: BoxFit.fill))
            ..marginIcon(EdgeInsets.zero)
            ..colorConfirmButton(AppColor.colorConfirmActionDialog)
            ..styleTextConfirmButton(const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w500,
                color: AppColor.colorActionDeleteConfirmDialog))
            ..onCloseButtonAction(() => popBack())
            ..onConfirmButtonAction(AppLocalizations.of(context).delete, () {
              _handleDeleteRecipientAction(listEmailAddress);
            })
            ..onCancelButtonAction(AppLocalizations.of(context).cancel, () =>
                popBack()))
          .build()));
    }
  }

  void selectAllRecipientForward() {
    if (selectionMode.value == SelectMode.INACTIVE) {
      selectionMode.value = SelectMode.ACTIVE;
    }

    listRecipientForward.value = listRecipientForward
        .map((recipient) => recipient.enableSelection())
        .toList();
  }

  void goToAddEmailsForward() async {
    final accountId = _accountDashBoardController.accountId.value;
    if (accountId != null) {
      final listEmail = await push(
          AppRoutes.EMAILS_FORWARD_CREATOR,
          arguments: MailsForwardCreatorArguments(accountId, _accountDashBoardController.sessionCurrent.value));

      if (listEmail is List<EmailAddress>) {
        _addEmailsForward(listEmail);
      }
    }
  }

  void _addEmailsForward(List<EmailAddress> listEmailAddress) {

  }
}