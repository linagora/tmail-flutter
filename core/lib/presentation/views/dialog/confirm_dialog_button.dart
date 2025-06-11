import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class ConfirmDialogButton extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final VoidCallback? onTapAction;

  const ConfirmDialogButton({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        overlayColor: Theme.of(context).colorScheme.outline.withOpacity(0.08),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(100)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10),
      ),
      onPressed: onTapAction,
      child: Text(
        label,
        style: ThemeUtils.textStyleM3LabelLarge(color: textColor),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
