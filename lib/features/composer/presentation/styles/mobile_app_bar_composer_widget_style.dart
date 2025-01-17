
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class MobileAppBarComposerWidgetStyle {
  static const double height = 56;
  static const double iconSize = 24;
  static const double space = 4;
  static const double sendButtonIconSize = 30;
  static const double richTextIconSize = 28;

  static const Color backgroundColor = AppColor.colorComposerAppBar;
  static const Color iconColor = AppColor.steelGrayA540;
  static const Color popupItemIconColor = AppColor.steelGrayA540;
  static const Color selectedBackgroundColor = AppColor.colorSelected;
  static const Color selectedIconColor = AppColor.blue700;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.symmetric(horizontal: 12);
  static const EdgeInsetsGeometry iconPadding = EdgeInsetsDirectional.all(3);
  static const EdgeInsetsGeometry richTextIconPadding = EdgeInsetsDirectional.all(5);
  static const EdgeInsetsGeometry popupItemPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);

  static const TextStyle popupItemTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
}