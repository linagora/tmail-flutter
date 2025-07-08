
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class AvatarSuggestionItemStyle {
  static const double iconSize = 40;
  static const double iconBorderSize = 1.0;

  static const Color iconColor = AppColor.avatarColor;
  static const Color iconBorderColor = AppColor.colorShadowBgContentEmail;

  static TextStyle labelTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w600
  );
}