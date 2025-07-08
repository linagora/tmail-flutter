import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class RuleFilterActionStyles {
  static const double extentRatio = 0.1;
  static const double removeButtonRadius = 110.0;
  static const double mainPadding = 12.0;
  static const double mainBorderRadius = 12.0;
  static const int maxLines = 1;
  static const double fontSize = 16.0;
  static const Color color = Colors.black;
  static TextStyle textStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.normal,
    fontSize: fontSize,
    color: color,
  );
  static const double itemDistance = 12.0;
  static TextStyle addActionButtonTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: 17.0,
    color: AppColor.primaryColor,
  );
}