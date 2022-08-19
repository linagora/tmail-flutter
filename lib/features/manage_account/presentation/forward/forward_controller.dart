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
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/manage_account/domain/model/delete_recipient_in_forwarding_request.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/delete_recipient_in_forwarding_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_forward_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/delete_recipient_in_forwarding_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_forward_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

class ForwardController extends BaseController {

  final GetForwardInteractor _getForwardInteractor;
  final DeleteRecipientInForwardingInteractor _deleteRecipientInForwardingInteractor;

  final _accountDashBoardController = Get.find<ManageAccountDashBoardController>();
  final _responsiveUtils = Get.find<ResponsiveUtils>();
  final _imagePaths = Get.find<ImagePaths>();
  final _appToast = Get.find<AppToast>();

  final currentForward = Rxn<TMailForward>();

  ForwardController(
    this._getForwardInteractor,
    this._deleteRecipientInForwardingInteractor,
  );

  @override
  void onDone() {
    viewState.value.fold((failure) {}, (success) {
      if (success is GetForwardSuccess) {
        currentForward.value = success.forward;
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
    if (accountId != null && currentForward.value != null) {
      consumeState(_deleteRecipientInForwardingInteractor.execute(
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
          icon: _imagePaths.icSelected);
    }

    currentForward.value = success.forward;
  }
}