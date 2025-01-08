
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class BottomBarComposerWidgetStyle {
  static const double iconRadius = 8;
  static const double space = 10;
  static const double sendButtonSpace = 12;
  static const double iconSize = 24;
  static const double sendButtonRadius = 8;
  static const double sendButtonIconSpace = 5;
  static const double height = 70;

  static const Color backgroundColor = Colors.white;
  static const Color iconColor = AppColor.steelGrayA540;
  static const Color sendButtonBackgroundColor = AppColor.blue700;
  static const Color selectedIconColor = AppColor.blue700;
  static const Color disabledIconColor = AppColor.colorRichButtonComposer;
  static const Color selectedBackgroundColor = AppColor.colorSelected;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.symmetric(horizontal: 32);
  static const EdgeInsetsGeometry iconPadding = EdgeInsetsDirectional.all(5);
  static const EdgeInsetsGeometry sendButtonPadding = EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 24);
  static const EdgeInsetsGeometry richTextIconPadding = EdgeInsetsDirectional.all(2);
  static const EdgeInsetsGeometry popupItemPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);

  static const TextStyle sendButtonTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: Colors.white,
  );
  static const TextStyle popupItemTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}