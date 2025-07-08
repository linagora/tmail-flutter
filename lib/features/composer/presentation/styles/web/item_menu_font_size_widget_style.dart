
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class ItemMenuFontSizeWidgetStyle {
  static TextStyle labelTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: Colors.black,
  );

  static const EdgeInsetsGeometry selectIconPadding = EdgeInsetsDirectional.only(start: 12);
}