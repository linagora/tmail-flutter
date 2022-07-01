import 'package:core/core.dart';
import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? landscapeMobile;
  final Widget? tablet;
  final Widget? landscapeTablet;
  final Widget? tabletLarge;
  final Widget? desktop;

  final ResponsiveUtils responsiveUtils;

  const ResponsiveWidget({
    Key? key,
    required this.responsiveUtils,
    required this.mobile,
    this.landscapeMobile,
    this.tablet,
    this.landscapeTablet,
    this.tabletLarge,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    log('ResponsiveWidget::build(): WIDTH_SIZE: ${responsiveUtils.getDeviceWidth(context)}');

    if (responsiveUtils.isLandscapeMobile(context)) {
      return landscapeMobile ?? mobile;
    }

    if (responsiveUtils.isLandscapeTablet(context)) {
      return landscapeTablet ?? tablet ?? mobile;
    }

    if (responsiveUtils.isMobile(context)) {
      return tablet ?? mobile;
    }

    if (responsiveUtils.isTablet(context)) {
      return tablet ?? mobile;
    }

    if (responsiveUtils.isTabletLarge(context)) {
      return tabletLarge ?? tablet ?? mobile;
    }

    if (responsiveUtils.isDesktop(context)) {
      return desktop ?? tablet ?? mobile;
    }

    return mobile;
  }
}