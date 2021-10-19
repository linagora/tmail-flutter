import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget tablet;
  final Widget? desktop;

  final ResponsiveUtils responsiveUtils;

  const ResponsiveWidget({
    Key? key,
    required this.mobile,
    required this.tablet,
    this.desktop,
    required this.responsiveUtils,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (responsiveUtils.isMobileDevice(context)) {
        return mobile;
      } else if (responsiveUtils.isDesktop(context)) {
        return desktop ?? tablet;
      } else if (responsiveUtils.isTablet(context)) {
        return tablet;
      } else {
        return mobile;
      }
    });
  }
}