
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class AppBarContactWidgetStyle {
  static EdgeInsetsGeometry getAppBarPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if (PlatformInfo.isWeb) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else {
      if (responsiveUtils.isScreenWithShortestSide(context)) {
        return const EdgeInsets.symmetric(horizontal: 10);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32);
      }
    }
  }
}