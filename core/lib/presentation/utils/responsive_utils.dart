import 'package:flutter/widgets.dart';

class ResponsiveUtils {

  static const int minDesktopWidth = 1366;
  static const int minTabletWidth = 600;
  static const int minTabletLargeWidth = 800;

  static const double _loginTextFieldWidthSmallScreen = 280.0;
  static const double _loginTextFieldWidthLargeScreen = 320.0;
  static const double _loginButtonWidth = 240.0;

  static const double _tabletHorizontalMargin = 144.0;
  static const double _tabletVerticalMargin = 234.0;
  static const double _desktopVerticalMargin = 144.0;
  static const double _desktopHorizontalMargin = 234.0;

  bool isMobileDevice(BuildContext context) => MediaQuery.of(context).size.shortestSide < 600;

  double getSizeWidthScreen(BuildContext context) => MediaQuery.of(context).size.width;

  double getSizeHeightScreen(BuildContext context) => MediaQuery.of(context).size.height;

  double getMinSizeScreen(BuildContext context) => MediaQuery.of(context).size.shortestSide;

  bool isMobile(BuildContext context) => getSizeWidthScreen(context) < minTabletWidth;

  bool isTablet(BuildContext context) => getSizeWidthScreen(context) >= minTabletWidth && getSizeWidthScreen(context) < minTabletLargeWidth;

  bool isDesktop(BuildContext context) => getSizeWidthScreen(context) > minDesktopWidth;

  bool isTabletLarge(BuildContext context) => getMinSizeScreen(context) >= minTabletLargeWidth && getMinSizeScreen(context) <= minDesktopWidth;

  bool isPortrait(BuildContext context) => MediaQuery.of(context).orientation == Orientation.portrait;

  bool isLandscape(BuildContext context) => MediaQuery.of(context).orientation == Orientation.landscape;

  double getWidthLoginTextField(BuildContext context) => isMobile(context) ? _loginTextFieldWidthSmallScreen : _loginTextFieldWidthLargeScreen;

  double getWidthLoginButton() => _loginButtonWidth;

  EdgeInsets getMarginDestinationPicker(BuildContext context) {
    if (isTablet(context)) {
      return getSizeHeightScreen(context) <= _tabletVerticalMargin * 2
        ? EdgeInsets.symmetric(
            horizontal: _tabletHorizontalMargin,
            vertical: 0.0)
        : EdgeInsets.symmetric(
            horizontal: _tabletHorizontalMargin,
            vertical: _tabletVerticalMargin);
    } else if (isDesktop(context)) {
      return getSizeHeightScreen(context) <= _desktopVerticalMargin * 2
        ? EdgeInsets.symmetric(
            horizontal: _desktopHorizontalMargin,
            vertical: 0.0)
        : EdgeInsets.symmetric(
            horizontal: _desktopHorizontalMargin,
            vertical: _desktopVerticalMargin);
    } else {
      return EdgeInsets.zero;
    }
  }

  BorderRadius radiusDestinationPicker(BuildContext context, double radius) {
    if (isTablet(context)) {
      return getSizeHeightScreen(context) <= _tabletVerticalMargin * 2
          ? BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius))
          : BorderRadius.circular(radius);
    } else if (isDesktop(context)) {
      return getSizeHeightScreen(context) <= _desktopVerticalMargin * 2
          ? BorderRadius.only(topLeft: Radius.circular(radius), topRight: Radius.circular(radius))
          : BorderRadius.circular(radius);
    } else {
      return BorderRadius.zero;
    }
  }
}