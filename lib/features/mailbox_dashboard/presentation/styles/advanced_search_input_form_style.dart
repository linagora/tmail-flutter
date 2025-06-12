import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class AdvancedSearchInputFormStyle {
  static TextStyle inputTextStyle = ThemeUtils.textStyleBodyBody3(
    color: AppColor.m3SurfaceBackground,
  );

  static const double inputFieldBorderRadius = 10;
  static const double inputFieldBorderWidth = 1;

  static const Color inputFieldBorderColor = AppColor.m3Neutral90;
  static const Color inputFieldBackgroundColor = Colors.white;
}
