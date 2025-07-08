import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class EmailRecoveryFormStyles {
  static const double iconClosePositionTop = 7;
  static const double iconClosePositionRight = 12;

  static const EdgeInsetsGeometry padding = EdgeInsets.only(top: 16);
  static const EdgeInsetsGeometry inputAreaPadding = EdgeInsets.all(20.0);
  static const EdgeInsetsGeometry bottomAreaPadding = EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 12,
  );

  static TextStyle titleTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: Colors.black,
  );
}