
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class SelectionWebAppBarThreadWidgetStyle {
  static const double minHeight = 56;
  static const double iconSize = 20;

  static const Color backgroundColor = Colors.white;
  static const Color iconColor = AppColor.steelGrayA540;

  static EdgeInsetsGeometry getPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isMobile(context) || responsiveUtils.isTabletLarge(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 8);
    }
  }

  static const TextStyle emailCounterStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColor.steelGrayA540
  );
}