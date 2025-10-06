import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class RecipientTagItemWidgetStyle {
  static const double radius = 10;
  static const double avatarIconSize = 20;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.only(start: 4);
  static const EdgeInsetsGeometry counterPadding = EdgeInsetsDirectional.symmetric(vertical: 5, horizontal: 8);
  static const EdgeInsetsGeometry mobileCounterPadding = EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 8);
  static const EdgeInsetsGeometry counterMargin = EdgeInsetsDirectional.only(start: 8);
  static const EdgeInsetsGeometry webMobileCounterMargin = EdgeInsetsDirectional.only(start: 8);
  static const EdgeInsetsGeometry webCounterMargin = EdgeInsetsDirectional.only(top: 8, start: 8);

  static TextStyle labelTextStyle = ThemeUtils.textStyleInter400.copyWith(
    color: Colors.black,
    fontSize: 17,
    height: 1.0,
    letterSpacing: -0.17,
  );

  static TextStyle avatarTextStyle = ThemeUtils.textStyleInter500().copyWith(
    color: Colors.white,
    fontSize: 14,
    height: 19.2 / 14,
    letterSpacing: 0.0,
  );
}