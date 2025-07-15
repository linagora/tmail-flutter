
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef IconWebCallback = void Function();
typedef OnTapIconButtonCallbackAction = void Function();
typedef OnTapDownIconButtonCallbackAction = void Function(TapDownDetails tapDetails);

Widget buildIconWeb({
  required Widget icon,
  String? tooltip,
  IconWebCallback? onTap,
  EdgeInsetsGeometry? iconPadding,
  double? iconSize,
  double? splashRadius,
  double? minSize,
  Color? colorSelected,
  Color? colorFocus,
  ShapeBorder? shapeBorder,
  EdgeInsetsGeometry? margin,
}) {
  return Container(
    margin: margin,
    child: Material(
        color: colorSelected ?? Colors.transparent,
        shape: shapeBorder ?? const CircleBorder(),
        child: IconButton(
            icon: icon,
            focusColor: colorFocus,
            iconSize: iconSize,
            constraints: minSize != null ? BoxConstraints(minWidth: minSize, minHeight: minSize) : null,
            padding: iconPadding ?? const EdgeInsets.all(8.0),
            splashRadius: splashRadius ?? 15,
            tooltip: tooltip ?? '',
            onPressed: onTap)
    ),
  );
}

Widget buildSVGIconButton({
  required String icon,
  String? tooltip,
  EdgeInsetsGeometry? padding,
  double? iconSize,
  Color? iconColor,
  OnTapIconButtonCallbackAction? onTap,
  OnTapDownIconButtonCallbackAction? onTapDown,
}) {
  Widget iconWidget = Padding(
    padding: padding ?? const EdgeInsets.all(8),
    child: SvgPicture.asset(
      icon,
      width: iconSize,
      height: iconSize,
      fit: BoxFit.fill,
      colorFilter: iconColor?.asFilter(),
    ),
  );

  Widget itemChild;
  if (tooltip != null) {
    itemChild = Tooltip(
      message: tooltip,
      child: iconWidget,
    );
  } else {
    itemChild = iconWidget;
  }

  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      onTapDown: onTapDown,
      customBorder: const CircleBorder(),
      child: itemChild,
    )
  );
}

Widget buildTextButton(String text, {
  TextStyle? textStyle,
  double? width,
  double? height,
  Color? backgroundColor,
  EdgeInsetsGeometry? padding,
  double? radius,
  IconWebCallback? onTap,
  FocusNode? focusNode,
}) {
  return SizedBox(
    width: width ?? double.infinity,
    height: height ?? 40,
    child: ElevatedButton(
        focusNode: focusNode,
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith((states) => backgroundColor ?? AppColor.colorTextButton),
            elevation: WidgetStateProperty.resolveWith((states) => 0),
            padding: WidgetStateProperty.resolveWith<EdgeInsetsGeometry>(
                (Set<WidgetState> states) => padding ?? const EdgeInsets.symmetric(horizontal: 8)),
            shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius ?? 0)))),
        child: Text(
            text,
            textAlign: TextAlign.center,
            style: textStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.w500)),
        onPressed: () => onTap?.call()
    ),
  );
}

Widget buildButtonWrapText(String name, {
  TextStyle? textStyle,
  Color? bgColor,
  Color? borderColor,
  double? radius,
  double? height,
  double? minWidth,
  EdgeInsetsGeometry? padding,
  FocusNode? focusNode,
  IconWebCallback? onTap
}) {
  return Container(
    height: height ?? 40,
    padding: padding,
    constraints: BoxConstraints(minWidth: minWidth ?? 0),
    child: ElevatedButton(
      focusNode: focusNode,
      onPressed: () => onTap?.call(),
      style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>(
              (Set<WidgetState> states) => bgColor ?? AppColor.colorTextButton),
          shape: WidgetStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 8),
              side: BorderSide(
                  width: borderColor != null ? 1 : 0,
                  color: borderColor ?? bgColor ?? AppColor.colorTextButton))),
          padding: WidgetStateProperty.resolveWith<EdgeInsets>(
              (Set<WidgetState> states) => const EdgeInsets.symmetric(horizontal: 16)),
          elevation: WidgetStateProperty.resolveWith<double>(
              (Set<WidgetState> states) => 0)),
      child: Text(name,
          textAlign: TextAlign.center,
          style: textStyle ??
              ThemeUtils.defaultTextStyleInterFont.copyWith(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
    ),
  );
}