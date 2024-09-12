
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class ThreadViewStyle {
  static EdgeInsetsGeometry getBannerMargin(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if (PlatformInfo.isWeb) {
      if (responsiveUtils.isMobile(context) || responsiveUtils.isTabletLarge(context)) {
        return const EdgeInsetsDirectional.only(start: 12, end: 12, bottom: 8);
      } else {
        return const EdgeInsetsDirectional.only(start: 24, end: 24, bottom: 8);
      }
    } else {
      if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeTablet(context)) {
        return const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 8);
      } else {
        return const EdgeInsetsDirectional.only(start: 32, end: 32, bottom: 8);
      }
    }
  }
}