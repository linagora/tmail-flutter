
import 'package:flutter/material.dart';

class ConfirmDialogButton extends StatelessWidget {

  final String label;
  final double? borderRadius;
  final Color backgroundColor;
  final EdgeInsetsGeometry? padding;
  final int? maxLines;
  final TextStyle? textStyle;
  final Color? textColor;
  final VoidCallback? onTapAction;

  const ConfirmDialogButton({
    super.key,
    required this.label,
    required this.backgroundColor,
    this.textStyle,
    this.borderRadius,
    this.padding,
    this.maxLines,
    this.textColor,
    this.onTapAction
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTapAction,
        borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
        child: Container(
          width: double.infinity,
          height: maxLines == 1 ? 44 : null,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? 10)),
          ),
          alignment: Alignment.center,
          padding: maxLines == 1
            ? const EdgeInsets.symmetric(horizontal: 8)
            : padding ?? const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: textStyle ?? Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: textColor,
            )
          ),
        ),
      ),
    );
  }
}
