
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class BottomBarComposerWidgetStyle {
  static const double iconRadius = 8;
  static const double space = 10;
  static const double sendButtonSpace = 12;
  static const double iconSize = 20;
  static const double richTextIconSize = 24;
  static const double sendButtonRadius = 8;
  static const double sendButtonIconSpace = 5;
  static const double height = 60;

  static const Color backgroundColor = Colors.white;
  static const Color iconColor = AppColor.colorRichButtonComposer;
  static const Color sendButtonBackgroundColor = AppColor.primaryColor;
  static const Color selectedBackgroundColor = AppColor.colorSelected;
  static const Color selectedIconColor = AppColor.primaryColor;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.symmetric(horizontal: 32);
  static const EdgeInsetsGeometry iconPadding = EdgeInsetsDirectional.all(5);
  static const EdgeInsetsGeometry sendButtonPadding = EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 24);
  static const EdgeInsetsGeometry richTextIconPadding = EdgeInsetsDirectional.all(2);
  static const TextStyle sendButtonTextStyle = TextStyle(
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: Colors.white,
  );
}