
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class DraggableRecipientTagWidgetStyle {
  static const double radius = 10;
  static const double avatarIconSize = 30;
  static const double avatarLabelFontSize = 10;

  static const Color avatarBackgroundColor = Colors.white;
  static const Color deleteIconColor = Colors.white;
  static const Color backgroundColor = AppColor.primaryColor;

  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(horizontal: 6, vertical: 3);
  static const EdgeInsetsGeometry labelPadding = EdgeInsets.symmetric(horizontal: 8);

  static const TextStyle avatarLabelTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 12,
    fontWeight: FontWeight.w500
  );
  static const TextStyle labelTextStyle = TextStyle(
    color: Colors.white,
    fontSize: 17,
    fontWeight: FontWeight.normal
  );
}