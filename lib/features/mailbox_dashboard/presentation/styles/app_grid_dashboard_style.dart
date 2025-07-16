import 'package:flutter/material.dart';

class AppGridDashboardStyle {
  static const double iconSize = 42;
  static const double hoverIconSize = 80;
  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.symmetric(horizontal: 10, vertical: 14);
  static final List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.15),
      blurRadius: 20,
      offset: Offset.zero
    ),
  ];
}