import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class DropZoneWidgetStyle {
  static const double space = 20;
  static const double borderWidth = 2;
  static const double radius = 16;

  static const List<double> dashSize = [6, 3];

  static const Color backgroundColor = AppColor.colorDropZoneBackground;
  static const Color borderColor = AppColor.colorDropZoneBorder;

  static const EdgeInsetsGeometry padding = EdgeInsets.all(20);
  static const EdgeInsetsGeometry margin = EdgeInsetsDirectional.symmetric(vertical: 8);

  static const TextStyle labelTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 22,
    fontWeight: FontWeight.w600
  );
}