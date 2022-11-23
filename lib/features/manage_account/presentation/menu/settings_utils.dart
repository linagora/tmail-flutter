import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';

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

  static EdgeInsets getPaddingAppBar(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  static EdgeInsets getMarginViewForSettingDetails(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb) {
      if (responsiveUtils.isDesktop(context)) {
        return const EdgeInsets.all(16);
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

  static BoxDecoration? getBoxDecorationForContent(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColor.colorBorderSettingContentWeb, width: 1),
        color: Colors.white);
    } else {
      return null;
    }
  }

  static Color? getContentBackgroundColor(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return null;
    } else {
      return Colors.white;
    }
  }

  static Color? getBackgroundColor(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return AppColor.colorBgDesktop;
    } else {
      return Colors.white;
    }
  }

  static EdgeInsets getPaddingListRecipientForwarding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else if (responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    }
  }

  static BoxDecoration? getBoxDecorationForListRecipient(BuildContext context, ResponsiveUtils responsiveUtils) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColor.colorBorderSettingContentWeb, width: 1),
      color: Colors.white);
  }

  static EdgeInsets getPaddingTitleHeaderForwarding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    }
  }

  static EdgeInsets getPaddingHeaderWidgetForwarding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsets.only(left: 16, right: 16);
    } else {
      return const EdgeInsets.all(12);
    }
  }

  static EdgeInsets getPaddingKeepLocalSwitchButtonForwarding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 18, vertical: 14);
    } else if (responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsets.all(14);
    } else {
      return const EdgeInsets.symmetric(horizontal: 34, vertical: 14);
    }
  }

  static EdgeInsets getPaddingInputRecipientForwarding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    }
  }

  static EdgeInsets getMarginViewForForwardSettingDetails(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsets.all(16);
    } else {
      return EdgeInsets.zero;
    }
  }
}