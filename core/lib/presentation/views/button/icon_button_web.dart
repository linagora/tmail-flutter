
import 'package:core/core.dart';
import 'package:flutter/material.dart';

typedef IconWebCallback = void Function();
typedef IconWebHasPositionCallback = void Function(RelativeRect);

Widget buildIconWeb({
  required Widget icon,
  String? tooltip,
  IconWebCallback? onTap,
  EdgeInsets? iconPadding,
  double? iconSize,
  double? splashRadius,
  double? minSize,
  Color? colorSelected,
  Color? colorFocus,
  ShapeBorder? shapeBorder,
}) {
  return Material(
      color: colorSelected ?? Colors.transparent,
      shape: shapeBorder ?? CircleBorder(),
      child: IconButton(
          icon: icon,
          focusColor: colorFocus,
          iconSize: iconSize,
          constraints: minSize != null ? BoxConstraints(minWidth: minSize, minHeight: minSize) : null,
          padding: iconPadding ?? EdgeInsets.all(8.0),
          splashRadius: splashRadius ?? 15,
          tooltip: tooltip ?? '',
          onPressed: onTap)
  );
}

Widget buildIconWebHasPosition(BuildContext context, {
  required Widget icon,
  String? tooltip,
  IconWebHasPositionCallback? onTapDown,
  IconWebCallback? onTap,
}) {
  return Material(
    color: Colors.transparent,
    shape: CircleBorder(),
    child: InkWell(
        onTapDown: (detail) {
          final screenSize = MediaQuery.of(context).size;
          final offset = detail.globalPosition;
          final position = RelativeRect.fromLTRB(
            offset.dx,
            offset.dy,
            screenSize.width - offset.dx,
            screenSize.height - offset.dy,
          );
          onTapDown?.call(position);
        },
        onTap: () => onTap?.call(),
        borderRadius: BorderRadius.all(Radius.circular(12)),
        child: Tooltip(
          message: tooltip ?? '',
          child: icon,
        )
    ),
  );
}

Widget buildTextCircleButton(String text, {
  TextStyle? textStyle,
  IconWebCallback? onTap,
}) {
  return Material(
      shape: CircleBorder(),
      color: Colors.transparent,
      child: TextButton(
          child: Text(
              text,
              style: textStyle ?? TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: AppColor.lineItemListColor)),
          style: ButtonStyle(
              overlayColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => AppColor.colorFocusButton),
              shape: MaterialStateProperty.all(CircleBorder()),
              padding: MaterialStateProperty.resolveWith<EdgeInsets>((Set<MaterialState> states) => EdgeInsets.zero),
              elevation: MaterialStateProperty.resolveWith<double>((Set<MaterialState> states) => 0)),
          onPressed: () => onTap?.call()
      )
  );
}

Widget buildTextIcon(String text, {
  TextStyle? textStyle,
  EdgeInsets? padding,
  IconWebCallback? onTap,
}) {
  return Material(
      shape: CircleBorder(),
      color: Colors.transparent,
      child: InkWell(
          child: Padding(
              padding: padding ?? EdgeInsets.all(10),
              child: Text(text, style: textStyle ?? TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: AppColor.lineItemListColor))),
          onTap: () => onTap?.call()
      )
  );
}

Widget buildTextButton(String text, {
  TextStyle? textStyle,
  double? width,
  double? height,
  Color? backgroundColor,
  EdgeInsets? padding,
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
            backgroundColor: MaterialStateProperty.resolveWith((states) => backgroundColor ?? AppColor.colorTextButton),
            elevation: MaterialStateProperty.resolveWith((states) => 0),
            padding: MaterialStateProperty.resolveWith<EdgeInsets>(
                (Set<MaterialState> states) => padding ?? EdgeInsets.symmetric(horizontal: 8)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius ?? 0)))),
        child: Text(
            text,
            textAlign: TextAlign.center,
            style: textStyle ?? TextStyle(
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
  EdgeInsets? padding,
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
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) => bgColor ?? AppColor.colorTextButton),
          shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(radius ?? 8),
              side: BorderSide(
                  width: borderColor != null ? 1 : 0,
                  color: borderColor ?? bgColor ?? AppColor.colorTextButton))),
          padding: MaterialStateProperty.resolveWith<EdgeInsets>(
              (Set<MaterialState> states) => const EdgeInsets.symmetric(horizontal: 16)),
          elevation: MaterialStateProperty.resolveWith<double>(
              (Set<MaterialState> states) => 0)),
      child: Text(name,
          textAlign: TextAlign.center,
          style: textStyle ??
              const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: Colors.white)),
    ),
  );
}