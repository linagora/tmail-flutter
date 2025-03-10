import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
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
      messageStyle: ThemeUtils.textStyleBodyBody2(color: AppColor.steelGray400),
      listTextSpan: [
        TextSpan(text: AppLocalizations.of(context).messageConfirmationLogout),
        TextSpan(
          text: ' $userAddress',
          style: ThemeUtils.textStyleBodyBody2(
            color: AppColor.steelGray400,
            fontWeight: FontWeight.w700,
          ),
        ),
        const TextSpan(text: '?'),
      ],
      onConfirmAction: onConfirmAction,
    );
  }
}
