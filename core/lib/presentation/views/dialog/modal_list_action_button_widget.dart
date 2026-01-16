import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/dialog/confirm_dialog_button.dart';
import 'package:flutter/material.dart';

class ModalListActionButtonWidget extends StatelessWidget {
  final String positiveLabel;
  final String negativeLabel;
  final VoidCallback onNegativeAction;
  final VoidCallback onPositiveAction;
  final EdgeInsetsGeometry? padding;
  final bool isPositiveActionEnabled;

  const ModalListActionButtonWidget({
    super.key,
    required this.positiveLabel,
    required this.negativeLabel,
    required this.onPositiveAction,
    required this.onNegativeAction,
    this.isPositiveActionEnabled = true,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Widget negativeButton = Container(
      constraints: const BoxConstraints(minWidth: 67),
      height: 48,
      child: ConfirmDialogButton(
        label: negativeLabel,
        onTapAction: onNegativeAction,
      ),
    );

    Widget positiveButton = Container(
      constraints: const BoxConstraints(minWidth: 153),
      height: 48,
      child: ConfirmDialogButton(
        label: positiveLabel,
        backgroundColor: isPositiveActionEnabled
            ? AppColor.primaryMain
            : AppColor.profileMenuDivider.withValues(alpha: 0.12),
        textColor: isPositiveActionEnabled
            ? Colors.white
            : AppColor.m3SurfaceBackground.withValues(alpha: 0.38),
        onTapAction: isPositiveActionEnabled ? onPositiveAction : null,
      ),
    );

    Widget bodyWidget = Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Flexible(child: negativeButton),
        const SizedBox(width: 8),
        Flexible(child: positiveButton),
      ],
    );

    if (padding != null) {
      return Padding(padding: padding!, child: bodyWidget);
    } else {
      return bodyWidget;
    }
  }
}
