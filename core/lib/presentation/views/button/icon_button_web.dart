
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef IconWebCallback = void Function();
typedef IconWebHasPositionCallback = void Function(RelativeRect);
typedef OnTapIconButtonCallbackAction = void Function();
typedef OnTapDownIconButtonCallbackAction = void Function(TapDownDetails TapDetails);

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
  );
}

Widget buildSVGIconButton({
  required String icon,
  String? tooltip,
  EdgeInsets? padding,
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
      color: iconColor,
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

Widget buildIconWebHasPosition(BuildContext context, {
  required Widget icon,
  String? tooltip,
  IconWebHasPositionCallback? onTapDown,
  IconWebCallback? onTap,
}) {
  return Material(
    color: Colors.transparent,
    shape: const CircleBorder(),
    child: InkWell(
        onTapDown: (detail) {
          onTapDown?.call(detail.getPosition(context));
        },
        onTap: () => onTap?.call(),
        borderRadius: const BorderRadius.all(Radius.circular(12)),
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
      shape: const CircleBorder(),
      color: Colors.transparent,
      child: TextButton(
          child: Text(
              text,
              style: textStyle ?? const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: AppColor.lineItemListColor)),
          style: ButtonStyle(
              overlayColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => AppColor.colorFocusButton),
              shape: MaterialStateProperty.all(const CircleBorder()),
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
      shape: const CircleBorder(),
      color: Colors.transparent,
      child: InkWell(
          child: Padding(
              padding: padding ?? const EdgeInsets.all(10),
              child: Text(text, style: textStyle ?? const TextStyle(fontWeight: FontWeight.normal, fontSize: 15, color: AppColor.lineItemListColor))),
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
                (Set<MaterialState> states) => padding ?? const EdgeInsets.symmetric(horizontal: 8)),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius ?? 0)))),
        child: Text(
            text,
            textAlign: TextAlign.center,
            style: textStyle ?? const TextStyle(
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

Widget buildIconWithLowerMenu(
  Widget icon,
  BuildContext context,
  List<PopupMenuEntry> popupMenuItems,
  Function(BuildContext context, RelativeRect? position,
          List<PopupMenuEntry> popupMenuItems)
      openPopUpMenuAction,
) {
  return Builder(
    builder: (iconContext) {
      final screenSize = MediaQuery.of(context).size;

      return buildIconWeb(
          icon: icon,
          onTap: () {
            // get size and position of the icon
            RenderBox box = iconContext.findRenderObject() as RenderBox;
            Offset iconTopLeft = box.localToGlobal(Offset.zero);
            final iconSize = box.size;

            // calculate the popup position for popup menu action
            final popupLeft = iconTopLeft.dx + iconSize.width * 3 / 4;
            final popupTop = iconTopLeft.dy + iconSize.height * 4 / 5;
            final popupRight = screenSize.width - popupLeft;
            final popupBottom = screenSize.height - popupRight;
            final position = RelativeRect.fromLTRB(
                popupLeft, popupTop, popupRight, popupBottom);

            openPopUpMenuAction(context, position, popupMenuItems);
          });
    },
  );
}

Widget buildIconWithUpperMenu(
  Widget icon,
  BuildContext context,
  List<PopupMenuEntry> popupMenuItems,
  Function(BuildContext context, RelativeRect? position,
          List<PopupMenuEntry> popupMenuItems)
      openPopUpMenuAction,
) {
  return Builder(
    builder: (iconContext) {
      final screenSize = MediaQuery.of(context).size;

      return buildIconWeb(
          icon: icon,
          onTap: () {
            // get size and position of the icon
            RenderBox box = iconContext.findRenderObject() as RenderBox;
            Offset iconTopLeft = box.localToGlobal(Offset.zero);
            final iconSize = box.size;

            // calculate the popup position for popup menu action
            final popupLeft = iconTopLeft.dx + iconSize.width * 3 / 4;
            final popupTop = iconTopLeft.dy - iconSize.height * 9 / 5;
            final popupRight = screenSize.width - popupLeft;
            final popupBottom = screenSize.height - popupRight;
            final position = RelativeRect.fromLTRB(
                popupLeft, popupTop, popupRight, popupBottom);

            openPopUpMenuAction(context, position, popupMenuItems);
          });
    },
  );
}