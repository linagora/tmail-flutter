import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

extension AppTextColors on BuildContext {
  Color get primaryTextColor {
    final isDark = Theme.of(this).brightness == Brightness.dark;
    return isDark
        ? AppColor.primaryDarkThemeTextColor
        : AppColor.primaryLightThemeTextColor;
  }
}
