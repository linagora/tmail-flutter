import 'package:flutter/widgets.dart';

class ResponsiveUtils {

  static const int minDesktopWidth = 1200;
  static const int minTabletWidth = 600;

  static const double _loginTextFieldWidthSmallScreen = 280.0;
  static const double _loginTextFieldWidthLargeScreen = 320.0;
  static const double _loginButtonWidth = 240.0;

  double getSizeWidthScreen(BuildContext context) => MediaQuery.of(context).size.width;

  double getSizeHeightScreen(BuildContext context) => MediaQuery.of(context).size.height;

  bool isMobile(BuildContext context) => getSizeWidthScreen(context) < minTabletWidth;

  bool isTablet(BuildContext context) => getSizeWidthScreen(context) >= minTabletWidth && getSizeWidthScreen(context) < minDesktopWidth;

  bool isDesktop(BuildContext context) => getSizeWidthScreen(context) >= minDesktopWidth;

  double getWidthLoginTextField(BuildContext context) => isMobile(context) ? _loginTextFieldWidthSmallScreen : _loginTextFieldWidthLargeScreen;

  double getWidthLoginButton() => _loginButtonWidth;
}