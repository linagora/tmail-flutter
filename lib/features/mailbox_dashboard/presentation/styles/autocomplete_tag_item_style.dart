import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AutocompleteTagItemStyle {
  static const double radius = 10;
  static const double space = 4;
  static const double deleteIconSize = 24;

  static Color get backgroundColor => AppColor.colorBackgroundTagFilter.withValues(alpha: 0.08);

  static const EdgeInsetsGeometry margin = EdgeInsetsDirectional.only(end: 8);
  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.only(start: 8, end: 4, top: 4, bottom: 4);

  static const TextStyle labelTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 17,
    fontWeight: FontWeight.normal
  );
}