
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class DraggableRecipientTagWidgetStyle {
  static const double radius = 10;
  static const double avatarIconSize = 24;
  static const double avatarLabelFontSize = 12;

  static const Color deleteIconColor = Colors.white;
  static const Color backgroundColor = AppColor.primaryColor;

  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(horizontal: 6, vertical: 3);
  static const EdgeInsetsGeometry labelPadding = EdgeInsets.symmetric(horizontal: 8);

  static TextStyle labelTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    color: Colors.white,
    fontSize: 17,
    fontWeight: FontWeight.normal
  );
}