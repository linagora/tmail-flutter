import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class DropdownButtonFontSizeWidgetStyle {
  static const double borderWidth = 0.5;
  static const double radius = 8;
  static const double height = 36;
  static const double labelRadius = 4;
  static const double space = 4;

  static const Color borderColor = AppColor.dropdownButtonBorderColor;
  static const Color labelBackgroundColor = AppColor.dropdownLabelButtonBackgroundColor;

  static const EdgeInsetsGeometry padding = EdgeInsets.all(4);
  static const EdgeInsetsGeometry labelPadding = EdgeInsets.symmetric(horizontal: 16);

  static TextStyle labelTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColor.colorLabelRichText
  );
}