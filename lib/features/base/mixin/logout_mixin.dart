import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/mixin/message_dialog_action_mixin.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

mixin LogoutMixin implements MessageDialogActionMixin {
  void showLogoutConfirmDialog({
    required BuildContext context,
    required String userAddress,
    required Function? onConfirmAction,
  }) {
    final appLocalizations = AppLocalizations.of(context);

    showConfirmDialogAction(
      context,
      '',
      appLocalizations.yesLogout,
      title: appLocalizations.logoutConfirmation,
      alignCenter: true,
      outsideDismissible: false,
      titleActionButtonMaxLines: 1,
      titlePadding: const EdgeInsetsDirectional.only(
        start: 24,
        top: 24,
        end: 24,
        bottom: 12,
      ),
      messageStyle: const TextStyle(
        color: AppColor.colorTextBody,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
      listTextSpan: [
        TextSpan(text: AppLocalizations.of(context).messageConfirmationLogout),
        TextSpan(
          text: ' $userAddress',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColor.colorTextBody,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const TextSpan(text: '?'),
      ],
      onConfirmAction: onConfirmAction,
    );
  }
}
