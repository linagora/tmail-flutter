import 'package:core/utils/app_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

class ResponsiveUtils {

  final int minDesktopWidth = 1200;
  final int minTabletWidth = 600;
  final int minTabletLargeWidth = 900;

  final double _loginTextFieldWidthSmallScreen = 280.0;
  final double _loginTextFieldWidthLargeScreen = 320.0;
  final double _loginButtonWidth = 240.0;

  final double tabletHorizontalMargin = 120.0;
  final double tabletVerticalMargin = 200.0;
  final double desktopVerticalMargin = 120.0;
  final double desktopHorizontalMargin = 200.0;

  bool isMobileDevice(BuildContext context) => context.mediaQueryShortestSide < minTabletWidth;

  double getSizeScreenWidth(BuildContext context) => context.width;

  double getSizeScreenHeight(BuildContext context) => context.height;

  double getSizeScreenShortestSide(BuildContext context) => context.mediaQueryShortestSide;

  double getDeviceWidth(BuildContext context) {
    final widthScreen = kIsWeb ? context.width : context.mediaQueryShortestSide;
    log('ResponsiveUtils::getDeviceWidth(): widthScreen: $widthScreen');
    return widthScreen;
  }

  bool isMobile(BuildContext context) => getDeviceWidth(context) < minTabletWidth;

  bool isTablet(BuildContext context) => getDeviceWidth(context) >= minTabletWidth && getDeviceWidth(context) < minTabletLargeWidth;

  bool isDesktop(BuildContext context) => getDeviceWidth(context) >= minDesktopWidth;

  bool isTabletLarge(BuildContext context) => getDeviceWidth(context) >= minTabletLargeWidth && getDeviceWidth(context) < minDesktopWidth;

  bool isPortrait(BuildContext context) =>  context.orientation == Orientation.portrait;

  bool isLandscape(BuildContext context) => context.orientation == Orientation.landscape;

  double getWidthLoginTextField(BuildContext context) => isMobile(context) ? _loginTextFieldWidthSmallScreen : _loginTextFieldWidthLargeScreen;

  double getWidthLoginButton() => _loginButtonWidth;
}