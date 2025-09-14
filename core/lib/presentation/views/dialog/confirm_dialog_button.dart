import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ConfirmDialogButton extends StatelessWidget {
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;
  final String? icon;
  final double? iconSize;
  final Color? iconColor;
  final TextStyle? textStyle;
  final double? radius;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTapAction;

  const ConfirmDialogButton({
    super.key,
    required this.label,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.icon,
    this.iconSize,
    this.iconColor,
    this.textStyle,
    this.radius,
    this.padding,
    this.onTapAction,
  });

  @override
  Widget build(BuildContext context) {
    final outlineBorder = borderColor != null
        ? RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius ?? 100)),
            side: BorderSide(width: 1, color: borderColor!),
          )
        : RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(radius ?? 100)),
          );

    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: backgroundColor,
        overlayColor: Theme.of(context).colorScheme.outline.withValues(alpha: 0.08),
        shape: outlineBorder,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 10),
      ),
      onPressed: onTapAction,
      child: icon == null
          ? Text(
              label,
              style: textStyle ?? ThemeUtils.textStyleM3LabelLarge(color: textColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SvgPicture.asset(
                  icon!,
                  width: iconSize ?? 14,
                  height: iconSize ?? 14,
                  fit: BoxFit.fill,
                  colorFilter: iconColor?.toInt() == Colors.transparent.toInt()
                      ? null
                      : iconColor?.asFilter() ?? AppColor.primaryMain.asFilter(),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    label,
                    style: textStyle ?? ThemeUtils.textStyleM3LabelLarge(color: textColor),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
    );
  }
}
