import 'package:flutter/widgets.dart';

class ResponsiveUtils {

  static const int minDesktopWidth = 1288;
  static const int minTabletWidth = 600;
  static const int minTabletLargeWidth = 900;

  static const double _loginTextFieldWidthSmallScreen = 280.0;
  static const double _loginTextFieldWidthLargeScreen = 320.0;
  static const double _loginButtonWidth = 240.0;

  final double tabletHorizontalMargin = 120.0;
  final double tabletVerticalMargin = 200.0;
  final double desktopVerticalMargin = 120.0;
  final double desktopHorizontalMargin = 200.0;

  bool isMobileDevice(BuildContext context) => MediaQuery.of(context).size.shortestSide < minTabletWidth;

  double getSizeWidthScreen(BuildContext context) => MediaQuery.of(context).size.width;

  double getSizeHeightScreen(BuildContext context) => MediaQuery.of(context).size.height;

  double getMinSizeScreen(BuildContext context) => MediaQuery.of(context).size.shortestSide;

  bool isMobile(BuildContext context) => getSizeWidthScreen(context) < minTabletWidth;

  bool isTablet(BuildContext context) => getSizeWidthScreen(context) >= minTabletWidth && getSizeWidthScreen(context) < minTabletLargeWidth;

  bool isDesktop(BuildContext context) => getSizeWidthScreen(context) > minDesktopWidth;

  bool isTabletLarge(BuildContext context) => getSizeWidthScreen(context) >= minTabletLargeWidth && getSizeWidthScreen(context) <= minDesktopWidth;

  bool isPortrait(BuildContext context) => MediaQuery.of(context).orientation == Orientation.portrait;

  bool isLandscape(BuildContext context) => MediaQuery.of(context).orientation == Orientation.landscape;

  double getWidthLoginTextField(BuildContext context) => isMobile(context) ? _loginTextFieldWidthSmallScreen : _loginTextFieldWidthLargeScreen;

  double getWidthLoginButton() => _loginButtonWidth;
}