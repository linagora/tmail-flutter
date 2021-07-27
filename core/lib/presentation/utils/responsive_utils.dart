import 'package:flutter/widgets.dart';

class ResponsiveUtils {

  static const int _minLargeWidth = 950;
  static const int _minMediumWidth = 600;

  static const double _loginTextFieldWidthSmallScreen = 280.0;
  static const double _loginTextFieldWidthLargeScreen = 320.0;
  static const double _loginButtonWidth = 240.0;

  double getSizeWidthScreen(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double getSizeHeightScreen(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  bool isLargeScreen(BuildContext context) {
    return getSizeWidthScreen(context) >= _minLargeWidth;
  }

  bool isSmallScreen(BuildContext context) {
    return getSizeWidthScreen(context) < _minMediumWidth;
  }

  bool isMediumScreen(BuildContext context) {
    return getSizeWidthScreen(context) >= _minMediumWidth && getSizeWidthScreen(context) < _minLargeWidth;
  }

  double getWidthLoginTextField(BuildContext context) => isSmallScreen(context)
    ? _loginTextFieldWidthSmallScreen
    : _loginTextFieldWidthLargeScreen;

  double getWidthLoginButton() => _loginButtonWidth;
}