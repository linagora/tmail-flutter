
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
}) {
  return Material(
      color: Colors.transparent,
      shape: CircleBorder(),
      child: IconButton(
          icon: icon,
          iconSize: iconSize,
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
  return InkWell(
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
      borderRadius: BorderRadius.all(Radius.circular(35)),
      child: Tooltip(
        message: tooltip ?? '',
        child: icon,
      )
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
}) {
  return SizedBox(
    width: width ?? double.infinity,
    height: height ?? 40,
    child: ElevatedButton(
        style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith((states) => backgroundColor ?? AppColor.colorTextButton),
            elevation: MaterialStateProperty.resolveWith((states) => 0),
            padding: MaterialStateProperty.resolveWith<EdgeInsets>(
                (Set<MaterialState> states) => padding ?? EdgeInsets.zero),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius ?? 0)))),
        child: Text(text, style: textStyle ?? TextStyle(fontSize: 17, color: Colors.white, fontWeight: FontWeight.w500)),
        onPressed: () => onTap?.call()
    ),
  );
}
