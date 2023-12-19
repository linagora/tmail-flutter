
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class SelectionWebAppBarThreadWidgetStyle {
  static const double minHeight = 56;
  static const double iconSize = 20;
  static const double mediumIconSize = 22;
  static const double closeButtonIconSize = 28;

  static const Color backgroundColor = Colors.white;
  static const Color cancelButtonColor = AppColor.primaryColor;

  static EdgeInsetsGeometry getPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isMobile(context) || responsiveUtils.isTabletLarge(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 8);
    }
  }
  static const EdgeInsetsGeometry closeButtonPadding = EdgeInsets.all(3);

  static const TextStyle emailCounterStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w500,
    color: AppColor.primaryColor
  );

  static Color getDeleteButtonColor(bool deletePermanentlyValid) {
    return deletePermanentlyValid
      ? AppColor.colorDeletePermanentlyButton
      : AppColor.primaryColor;
  }
}