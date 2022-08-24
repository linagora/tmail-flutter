import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/widgets.dart';

class SettingsUtils {
  static double getHorizontalPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isMobile(context)) {
      return 16;
    } else {
      return 32;
    }
  }

  static EdgeInsets getPaddingInFirstLevel(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isMobile(context)) {
      return const EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 16);
    } else {
      return const EdgeInsets.only(left: 32, top: 12, bottom: 12, right: 32);
    }
  }

  static EdgeInsets getMarginViewForSettingDetails(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb) {
      if (responsiveUtils.isDesktop(context)) {
        return const EdgeInsets.only(left: 16, top: 16, right: 24, bottom: 24);
      } else if (responsiveUtils.isTabletLarge(context) ||
          responsiveUtils.isTablet(context)) {
        return const EdgeInsets.only(right: 32, top: 16, bottom: 16, left: 32);
      } else {
        return const EdgeInsets.only(right: 16, top: 16, bottom: 16, left: 16);
      }
    } else {
      if (responsiveUtils.isLandscapeTablet(context) ||
        responsiveUtils.isTabletLarge(context) ||
        responsiveUtils.isTablet(context)) {
        return const EdgeInsets.only(right: 32, top: 16, bottom: 16, left: 32);
      } else if (responsiveUtils.isDesktop(context)) {
        return const EdgeInsets.only(right: 32, top: 16, bottom: 16);
      } else {
        return const EdgeInsets.only(right: 16, top: 16, bottom: 16, left: 16);
      }
    }
  }
}