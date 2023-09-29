
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class TitleAppBarThreadWidgetStyle {
  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: 8, horizontal: 16);

  static const TextStyle titleStyle = TextStyle(
    fontSize: 21,
    color: Colors.black,
    fontWeight: FontWeight.w700
  );
  static const TextStyle filterOptionStyle = TextStyle(
    fontSize: 11,
    color: AppColor.colorContentEmail
  );
}