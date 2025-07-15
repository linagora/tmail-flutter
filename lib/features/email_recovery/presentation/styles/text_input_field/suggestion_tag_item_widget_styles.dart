import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class SuggestionTagItemWidgetStyles {
  static const double paddingTop = 4.5;
  static const double paddingEndCollapsed = 40.0;
  static const double paddingEndExpanded = 0.0;
  static const double labelPaddingHorizontal = 4.0;
  static const double labelPaddingVertical = 2.0;
  static const double collapsedTextBorderRadius = 10.0;

  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(10));

  static const EdgeInsetsGeometry collapsedTextMargin = EdgeInsets.only(
    top: 5.5,
  );
  static const EdgeInsetsGeometry collapsedTextPadding = EdgeInsetsDirectional.symmetric(
    vertical: 5,
    horizontal: 8,
  );

  static const BorderSide latestTagBorderSide = BorderSide(
    color: AppColor.primaryColor,
    width: 1,
  );

  static TextStyle labelStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    color: Colors.black,
    fontSize: 17,
    fontWeight: FontWeight.w400
  );
}