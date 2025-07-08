
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class AppBarSendingQueueWidgetStyle {
  static const double height = 52;
  static const double leadingRadius = 15;
  static const double space = 8;
  static const double trailingSize = 50;

  static const Color backgroundColor = Colors.white;
  static const Color iconColor = AppColor.colorTextButton;

  static const EdgeInsetsGeometry leadingPadding = EdgeInsetsDirectional.only(start: 8);
  static const EdgeInsetsGeometry selectIconPadding = EdgeInsets.symmetric(horizontal: 10, vertical: 5);

  static EdgeInsetsGeometry getPaddingAppBarByResponsiveSize(double width) {
    if (ResponsiveUtils.isMatchedMobileWidth(width)) {
      return const EdgeInsets.symmetric(horizontal: 10);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  static TextStyle countStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 17,
    color: AppColor.colorTextButton
  );
  static TextStyle labelStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 21,
    color: Colors.black,
    fontWeight: FontWeight.bold
  );
}