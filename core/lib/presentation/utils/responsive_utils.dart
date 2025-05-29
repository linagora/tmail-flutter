import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ResponsiveUtils {

  static const double defaultSizeLeftMenuMobile = 375;
  static const double defaultSizeDrawer = 320;
  static const double defaultSizeMenu = 256;
  static const double mobileLeftMenuSize = 339;

  static const int heightShortest = 600;

  static const int minDesktopWidth = 1200;
  static const int minTabletWidth = 600;
  static const int minTabletLargeWidth = 900;

  static const double tabletHorizontalMargin = 120.0;
  static const double tabletVerticalMargin = 200.0;
  static const double desktopVerticalMargin = 120.0;
  static const double desktopHorizontalMargin = 200.0;

  bool isScreenWithShortestSide(BuildContext context) => getSizeScreenShortestSide(context) < minTabletWidth;

  double getSizeScreenWidth(BuildContext context) => MediaQuery.sizeOf(context).width;

  double getSizeScreenHeight(BuildContext context) => MediaQuery.sizeOf(context).height;

  double getSizeScreenShortestSide(BuildContext context) => MediaQuery.sizeOf(context).shortestSide;

  double getDeviceWidth(BuildContext context) => MediaQuery.sizeOf(context).width;

  bool isMobile(BuildContext context) => getDeviceWidth(context) < minTabletWidth;

  bool isTablet(BuildContext context) =>
      getDeviceWidth(context) >= minTabletWidth && getDeviceWidth(context) < minTabletLargeWidth;

  bool isDesktop(BuildContext context) => getDeviceWidth(context) >= minDesktopWidth;

  bool isTabletLarge(BuildContext context) =>
      getDeviceWidth(context) >= minTabletLargeWidth && getDeviceWidth(context) < minDesktopWidth;

  bool isPortrait(BuildContext context) =>  context.orientation == Orientation.portrait;

  bool isLandscape(BuildContext context) => context.orientation == Orientation.landscape;

  bool isLandscapeMobile(BuildContext context) => isScreenWithShortestSide(context) && isLandscape(context);

  bool isLandscapeTablet(BuildContext context) {
    return getSizeScreenShortestSide(context) >= minTabletWidth &&
        getSizeScreenShortestSide(context) < minDesktopWidth &&
        isLandscape(context);
  }

  bool isPortraitMobile(BuildContext context) => isScreenWithShortestSide(context) && isPortrait(context);

  bool isPortraitTablet(BuildContext context) {
    return getSizeScreenShortestSide(context) >= minTabletWidth &&
        getSizeScreenShortestSide(context) < minDesktopWidth &&
        isPortrait(context);
  }

  bool isHeightShortest(BuildContext context) {
    return getSizeScreenShortestSide(context) < heightShortest;
  }

  double getMaxWidthToast(BuildContext context) {
    final widthScreen = getSizeScreenWidth(context);
    if (isPortraitMobile(context)) {
      return widthScreen;
    } else {
      return widthScreen < 424 ? widthScreen : 424;
    }
  }

  bool hasLeftMenuDrawerActive(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return isMobile(context) ||
          isTablet(context) ||
          isTabletLarge(context);
    } else {
      return true;
    }
  }

  bool isWebDesktop(BuildContext context) =>
      PlatformInfo.isWeb && isDesktop(context);

  bool isWebNotDesktop(BuildContext context) =>
      PlatformInfo.isWeb && !isDesktop(context);

  bool mailboxDashboardOnlyHasEmailView(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return isMobile(context) || isTablet(context);
    } else {
      return isPortraitMobile(context) ||
          isLandscapeMobile(context) ||
          isTablet(context);
    }
  }

  bool landscapeTabletSupported(BuildContext context) {
    if (PlatformInfo.isWeb) {
      return isTabletLarge(context);
    } else {
      return !isLandscapeMobile(context) && (isLandscapeTablet(context) ||
          isTabletLarge(context) ||
          isDesktop(context));
    }
  }

  bool isMatchedDesktopWidth(double width) => width >= minDesktopWidth;

  static bool isMatchedMobileWidth(double width) => width < minTabletWidth;
}