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
      listTextSpan: [
        TextSpan(text: AppLocalizations.of(context).messageConfirmationLogout),
        TextSpan(
          text: ' $userAddress',
          style: ThemeUtils.textStyleM3BodyMedium1.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const TextSpan(text: '?'),
      ],
      onConfirmAction: onConfirmAction,
    );
  }
}
