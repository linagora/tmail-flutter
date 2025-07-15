
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class TitleAppBarThreadWidgetStyle {
  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(vertical: 8, horizontal: 16);

  static TextStyle titleStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 21,
    color: Colors.black,
    fontWeight: FontWeight.w700,
  );
  static TextStyle filterOptionStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 11,
    color: AppColor.colorContentEmail,
  );
}