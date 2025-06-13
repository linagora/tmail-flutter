import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/bottom_popup/confirmation_dialog_action_sheet_builder.dart';
import 'package:core/presentation/views/dialog/confirmation_dialog_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';
import 'package:tmail_ui_user/features/base/base_mailbox_controller.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/empty_folder_name_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/exceptions/invalid_mail_format_exception.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_subaddressing_action.dart';
import 'package:tmail_ui_user/features/mailbox/domain/state/subaddressing_mailbox_state.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/copy_subaddress_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';

extension HandleMailboxActionTypeExtension on BaseMailboxController {
  void copySubAddressAction(BuildContext context, String subAddress) {
    Clipboard.setData(ClipboardData(text: subAddress));
    appToast.showToastSuccessMessage(
      context,
      AppLocalizations.of(context).emailSubaddressCopiedToClipboard,
    );
  }

  String getSubAddress(String userEmail, String folderName) {
    if (folderName.isEmpty) {
      throw EmptyFolderNameException(folderName);
    }

    final atIndex = userEmail.indexOf('@');
    if (atIndex <= 0 || atIndex == userEmail.length - 1) {
      throw InvalidMailFormatException(userEmail);
    }

    return '${userEmail.substring(0, atIndex)}+$folderName@${userEmail.substring(atIndex + 1)}';
  }

  void openConfirmationDialogSubAddressingAction(
      BuildContext context,
      MailboxId mailboxId,
      String mailboxName,
      String subAddress,
      Map<String, List<String>?>? currentRights,
      {
        required AllowSubaddressingActionCallback onAllowSubAddressingAction
      }
  ) {
    if (responsiveUtils.isLandscapeMobile(context) ||
        responsiveUtils.isPortraitMobile(context)) {
      (ConfirmationDialogActionSheetBuilder(context)
        ..messageText(AppLocalizations.of(context)
          .message_confirmation_dialog_allow_subaddressing_mobile(
            mailboxName,
            subAddress,
          )
        )
        ..onCancelAction(AppLocalizations.of(context).cancel, popBack)
        ..onConfirmAction(
            AppLocalizations.of(context).allow,
            () => onAllowSubAddressingAction(
                mailboxId,
                currentRights,
                MailboxActions.allowSubaddressing,
            ))
      ).show();
    } else {
      Get.dialog(
        PointerInterceptor(
          child: ConfirmationDialogBuilder(
            key: const Key('confirm_dialog_subAddressing'),
            imagePath: imagePaths,
            title: AppLocalizations.of(context).allowSubaddressing,
            textContent: AppLocalizations.of(context)
                .message_confirmation_dialog_allow_subaddressing(mailboxName),
            confirmText: AppLocalizations.of(context).allow,
            cancelText: AppLocalizations.of(context).cancel,
            additionalWidgetContent: CopySubaddressWidget(
              imagePath: imagePaths,
              subaddress: subAddress,
              onCopyButtonAction: () => copySubAddressAction(
                context,
                subAddress,
              ),
            ),
            onConfirmButtonAction: () => onAllowSubAddressingAction(
              mailboxId,
              currentRights,
              MailboxActions.allowSubaddressing,
            ),
            onCancelButtonAction: popBack,
            onCloseButtonAction: popBack,
          ),
        ),
        barrierColor: AppColor.colorDefaultCupertinoActionSheet,
      );
    }
  }

  void handleSubAddressingFailure(SubaddressingFailure failure) {
    if (currentOverlayContext != null && currentContext != null) {
      final messageError = AppLocalizations.of(currentContext!).toastMessageSubaddressingFailure;
      appToast.showToastErrorMessage(currentOverlayContext!, messageError);
    }
  }

  void handleSubAddressingSuccess(SubaddressingSuccess success) {
    appToast.showToastSuccessMessage(
      currentOverlayContext!,
      success.subaddressingAction == MailboxSubaddressingAction.allow
          ? AppLocalizations.of(currentContext!).toastMessageAllowSubaddressingSuccess
          : AppLocalizations.of(currentContext!).toastMessageDisallowSubaddressingSuccess,
    );
  }
}
