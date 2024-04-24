
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class TabletContainerViewStyle {
  static const double radius = 28;
  static const double elevation = 16;

  static const Color backgroundColor = Colors.white;
  static const Color outSideBackgroundColor = Colors.black38;
  static final Color keyboardToolbarBackgroundColor = PlatformInfo.isIOS
    ? AppColor.colorBackgroundKeyboard
    : AppColor.colorBackgroundKeyboardAndroid;

  static EdgeInsetsGeometry getMargin(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if (responsiveUtils.isTablet(context)) {
      return const EdgeInsetsDirectional.all(24);
    } else {
      return const EdgeInsetsDirectional.symmetric(vertical: 24);
    }
  }

  static double getWidth(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    final currentWidth = responsiveUtils.getSizeScreenWidth(context);
    if (responsiveUtils.isTablet(context)) {
      return currentWidth;
    } else {
      return currentWidth * 0.7;
    }
  }
}