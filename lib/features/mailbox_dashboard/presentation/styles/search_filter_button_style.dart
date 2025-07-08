import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class SearchFilterButtonStyle {
  static const double iconSize = 16;
  static const double deleteIconSize = 10;
  static const double spaceSize = 4;

  static EdgeInsetsGeometry getButtonPadding(bool isSelected) {
    if (isSelected) {
      return const EdgeInsetsDirectional.only(start: 12, end: 4, top: 4, bottom: 4);
    } else {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    }
  }
  static const EdgeInsetsGeometry elementPadding = EdgeInsetsDirectional.only(start: 8);
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(10));

  static TextStyle titleStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColor.colorSearchFilterTitle);
}