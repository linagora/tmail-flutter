import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class RecoverDeletedMessageLoadingBannerStyle {
  static EdgeInsetsGeometry getBannerMargin(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if (PlatformInfo.isWeb) {
      if (responsiveUtils.isDesktop(context)) {
        return const EdgeInsetsDirectional.only(end: 16, bottom: 8);
      } else if (responsiveUtils.isTablet(context)) {
        return const EdgeInsetsDirectional.only(bottom: 8, start: 24, end: 24);
      } else {
        return const EdgeInsetsDirectional.only(bottom: 8, start: 12, end: 12);
      }
    } else {
      if (responsiveUtils.isPortraitTablet(context)) {
        return const EdgeInsetsDirectional.only(bottom: 8, start: 32, end: 32);
      } else {
        return const EdgeInsetsDirectional.only(bottom: 8, start: 16, end: 16);
      }
    }
  }
}