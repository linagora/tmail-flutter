import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class RecipientTagItemWidgetStyle {
  static const double radius = 10;
  static const double avatarIconSize = 24;
  static const double avatarLabelFontSize = 12;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.only(start: 4);
  static const EdgeInsetsGeometry counterPadding = EdgeInsetsDirectional.symmetric(vertical: 5, horizontal: 8);
  static const EdgeInsetsGeometry mobileCounterPadding = EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 8);
  static const EdgeInsetsGeometry counterMargin = EdgeInsetsDirectional.only(top: PlatformInfo.isWeb ? 8 : 0, start: 8);

  static const TextStyle labelTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 17,
    fontWeight: FontWeight.w400
  );
}