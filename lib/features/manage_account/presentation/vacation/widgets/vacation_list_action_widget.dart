import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class VacationListActionWidget extends StatelessWidget {
  final VoidCallback onConfirmButtonAction;
  final VoidCallback onCancelButtonAction;

  const VacationListActionWidget({
    super.key,
    required this.onConfirmButtonAction,
    required this.onCancelButtonAction,
  });

  @override
  Widget build(BuildContext context) {
    final appLocalizations = AppLocalizations.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            constraints: const BoxConstraints(minWidth: 67),
            height: 48,
            child: ConfirmDialogButton(
              label: appLocalizations.cancel,
              onTapAction: onCancelButtonAction,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Container(
            constraints: const BoxConstraints(minWidth: 139),
            height: 48,
            child: ConfirmDialogButton(
              label: appLocalizations.saveChanges,
              backgroundColor: AppColor.primaryMain,
              textColor: Colors.white,
              onTapAction: onConfirmButtonAction,
            ),
          ),
        ),
      ],
    );
  }
}
