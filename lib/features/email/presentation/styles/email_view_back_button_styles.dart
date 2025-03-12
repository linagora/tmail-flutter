
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class EmailViewBackButtonStyles {
  static const double offsetWidth = 270;

  static const Color iconColor = AppColor.steelGrayA540;

  static const EdgeInsetsGeometry rtlPadding = EdgeInsetsDirectional.symmetric(horizontal: 8);

  static final TextStyle labelTextStyle = ThemeUtils.textStyleBodyBody2(
    color: AppColor.steelGrayA540,
  );
}