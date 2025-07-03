import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class SettingsUtils {
  SettingsUtils._();

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
    if (PlatformInfo.isWeb) {
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

  static BoxDecoration? getBoxDecorationForContent(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
    {
      Color backgroundColor = Colors.white
    }
  ) {
    if (responsiveUtils.isWebDesktop(context)) {
      return BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        color: backgroundColor,
      );
    } else {
      return null;
    }
  }

  static Color? getContentBackgroundColor(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
    {
      Color backgroundColor = Colors.white
    }
  ) {
    if (responsiveUtils.isWebDesktop(context)) {
      return null;
    } else {
      return backgroundColor;
    }
  }

  static Color? getBackgroundColor(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return AppColor.colorBgDesktop;
    } else {
      return Colors.white;
    }
  }

  static EdgeInsetsGeometry getSettingContentPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
  ) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsets.all(16);
    } else if (responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    }
  }

  static EdgeInsetsGeometry getSettingContentWithoutHeaderPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
  ) {
    if (responsiveUtils.isWebDesktop(context)) {
      return EdgeInsets.zero;
    } else if (responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    }
  }

  static EdgeInsetsGeometry getSettingProgressBarPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
  ) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsetsDirectional.only(end: 16, top: 16);
    } else if (responsiveUtils.isTablet(context) ||
        responsiveUtils.isTabletLarge(context)) {
      return const EdgeInsetsDirectional.only(start: 32, end: 32, top: 16);
    } else {
      return const EdgeInsetsDirectional.only(start: 16, end: 16, top: 16);
    }
  }

  static EdgeInsetsGeometry? getMarginSettingDetailsView(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
  ) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsetsDirectional.only(end: 16, top: 16, bottom: 16);
    } else {
      return null;
    }
  }

  static EdgeInsetsGeometry getPreferencesSettingPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsets.all(24);
    } else {
      return const EdgeInsetsDirectional.symmetric(vertical: 8);
    }
  }

  static EdgeInsetsGeometry getForwardBannerPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
  ) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsetsDirectional.only(start: 16, end: 16, top: 16);
    } else if (responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    } else if (responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    }
  }
}