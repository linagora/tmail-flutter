import 'package:core/utils/build_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ResponsiveUtils {

  static const double defaultSizeLeftMenuMobile = 375;
  static const double defaultSizeDrawer = 320;

  final int heightShortest = 600;

  final int minDesktopWidth = 1200;
  final int minTabletWidth = 600;
  final int minTabletLargeWidth = 900;

  final double defaultSizeMenu = 256;

  final double _loginTextFieldWidthSmallScreen = 280.0;
  final double _loginTextFieldWidthLargeScreen = 320.0;
  final double _loginButtonWidth = 240.0;

  final double tabletHorizontalMargin = 120.0;
  final double tabletVerticalMargin = 200.0;
  final double desktopVerticalMargin = 120.0;
  final double desktopHorizontalMargin = 200.0;

  bool isScreenWithShortestSide(BuildContext context) => context.mediaQueryShortestSide < minTabletWidth;

  double getSizeScreenWidth(BuildContext context) => context.width;

  double getSizeScreenHeight(BuildContext context) => context.height;

  double getSizeScreenShortestSide(BuildContext context) => context.mediaQueryShortestSide;

  double getDeviceWidth(BuildContext context) => context.width;

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
    return context.mediaQueryShortestSide >= minTabletWidth &&
        context.mediaQueryShortestSide < minDesktopWidth &&
        isLandscape(context);
  }

  bool isPortraitMobile(BuildContext context) => isScreenWithShortestSide(context) && isPortrait(context);

  bool isPortraitTablet(BuildContext context) {
    return context.mediaQueryShortestSide >= minTabletWidth &&
        context.mediaQueryShortestSide < minDesktopWidth &&
        isPortrait(context);
  }

  double getWidthLoginTextField(BuildContext context) =>
      isMobile(context) ? _loginTextFieldWidthSmallScreen : _loginTextFieldWidthLargeScreen;

  double getWidthLoginButton() => _loginButtonWidth;

  bool isHeightShortest(BuildContext context) {
    return MediaQuery.of(context).size.shortestSide < heightShortest;
  }

  double getMaxWidthToast(BuildContext context) {
    final widthScreen = getSizeScreenWidth(context);
    if (isPortraitMobile(context)) {
      return widthScreen;
    } else {
      return widthScreen < 444 ? widthScreen : 444;
    }
  }

  bool hasLeftMenuDrawerActive(BuildContext context) {
    if (BuildUtils.isWeb) {
      return isMobile(context) ||
          isTablet(context) ||
          isTabletLarge(context);
    } else {
      return true;
    }
  }

  bool isWebDesktop(BuildContext context) =>
      BuildUtils.isWeb && isDesktop(context);

  bool mailboxDashboardHasMailboxAndEmailView(BuildContext context) {
    if (BuildUtils.isWeb) {
      return isDesktop(context) ||
          isMobile(context) ||
          isTablet(context);
    } else {
      return isPortraitMobile(context) ||
          isLandscapeMobile(context) ||
          isTablet(context);
    }
  }

  bool mailboxDashboardOnlyHasEmailView(BuildContext context) {
    if (BuildUtils.isWeb) {
      return isMobile(context) || isTablet(context);
    } else {
      return isPortraitMobile(context) ||
          isLandscapeMobile(context) ||
          isTablet(context);
    }
  }

  bool isMailboxDashboardSplitView(BuildContext context) {
    if (BuildUtils.isWeb) {
      return isTabletLarge(context);
    } else {
      return isLandscapeTablet(context) || isDesktop(context);
    }
  }
}