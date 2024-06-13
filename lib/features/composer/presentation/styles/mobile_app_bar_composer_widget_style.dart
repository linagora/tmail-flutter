
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class MobileAppBarComposerWidgetStyle {
  static const double height = 56;
  static const double iconSize = 24;
  static const double space = 12;
  static const double iconRadius = 8;
  static const double sendButtonIconSize = 30;
  static const double richTextIconSize = 28;

  static const Color backgroundColor = AppColor.colorComposerAppBar;
  static const Color iconColor = AppColor.colorMobileRichButtonComposer;
  static const Color selectedBackgroundColor = AppColor.colorSelected;
  static const Color selectedIconColor = AppColor.primaryColor;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.symmetric(horizontal: 12);
  static const EdgeInsetsGeometry iconPadding = EdgeInsetsDirectional.all(3);
  static const EdgeInsetsGeometry richTextIconPadding = EdgeInsetsDirectional.all(5);
}