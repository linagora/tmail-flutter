
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class AutocompleteSuggestionItemStyle {
  static const double space = 10;

  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: 10, horizontal: 12);

  static TextStyle displayNameTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.normal
  );
  static TextStyle emailAddressNameTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    color: AppColor.colorHintSearchBar,
    fontSize: 13,
    fontWeight: FontWeight.normal
  );
}