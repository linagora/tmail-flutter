import 'package:flutter/material.dart';

class PopupItemWidgetStyle {
  static const double iconSize = 20;
  static const double selectedIconSize = 16;
  static const double space = 16;
  static const double height = 48;
  static const double minWidth = 256;

  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  static const EdgeInsetsGeometry iconSelectedPadding = EdgeInsetsDirectional.only(start: 12);

  static const TextStyle labelTextStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.normal,
    color: Colors.black
  );
}