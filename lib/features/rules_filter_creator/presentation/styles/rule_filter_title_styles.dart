import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class RuleFilterTitleStyles {
  static const double fontSize = 16.0;
  static const Color textColor = Colors.black;
  static TextStyle textStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w500,
    fontSize: fontSize,
    color: textColor,
  );
  static const int textMaxLines = 1;
  static const double combinerTypeSelectionAreaWith = 200.0;
  static const double combinerTypeSelectionAreaPadding = 12.0;
}