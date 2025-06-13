import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class PopupItemWidgetStyle {
  static const double iconSize = 20;
  static const double selectedIconSize = 16;
  static const double space = 16;
  static const double height = 48;
  static const double maxWidth = 300;

  static const EdgeInsetsGeometry iconSelectedPadding =
    EdgeInsetsDirectional.only(start: 16);

  static final TextStyle labelTextStyle = ThemeUtils.textStyleBodyBody3(
    color: Colors.black,
  );
}