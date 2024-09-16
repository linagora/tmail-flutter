import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class SearchFilterButtonStyle {
  static const double iconSize = 16;
  static const double deleteIconSize = 10;
  static const double spaceSize = 4;

  static const EdgeInsetsGeometry buttonPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const EdgeInsetsGeometry elementPadding = EdgeInsetsDirectional.only(start: 8);
  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(10));

  static const TextStyle titleStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.normal,
    color: AppColor.colorTextButtonHeaderThread);
}