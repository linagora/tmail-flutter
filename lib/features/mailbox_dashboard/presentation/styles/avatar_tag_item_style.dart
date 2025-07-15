import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class AvatarTagItemStyle {
  static const double iconSize = 24;
  static const double iconBorderSize = 0.21;

  static const Color iconBorderColor = AppColor.colorShadowBgContentEmail;

  static TextStyle labelTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    color: Colors.white,
    fontSize: 8.57,
    fontWeight: FontWeight.w600
  );
}