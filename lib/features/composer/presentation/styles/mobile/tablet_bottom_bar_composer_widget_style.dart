
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class TabletBottomBarComposerWidgetStyle {
  static const double iconRadius = 8;
  static const double space = 10;
  static const double sendButtonSpace = 12;
  static const double iconSize = 20;
  static const double sendButtonRadius = 8;
  static const double sendButtonIconSpace = 5;

  static const Color backgroundColor = Colors.white;
  static const Color iconColor = AppColor.colorRichButtonComposer;
  static const Color sendButtonBackgroundColor = AppColor.primaryColor;
  static const Color selectedIconColor = AppColor.primaryColor;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.symmetric(horizontal: 32, vertical: 12);
  static const EdgeInsetsGeometry iconPadding = EdgeInsetsDirectional.all(5);
  static const EdgeInsetsGeometry sendButtonPadding = EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 24);
  static TextStyle sendButtonTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: 15,
    color: Colors.white,
  );
}