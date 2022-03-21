import 'package:core/core.dart';
import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? tabletLarge;
  final Widget? desktop;

  final ResponsiveUtils responsiveUtils;

  const ResponsiveWidget({
    Key? key,
    required this.responsiveUtils,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.tabletLarge,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (desktop != null && responsiveUtils.isDesktop(context)) return desktop!;
    if (tabletLarge != null && responsiveUtils.isTabletLarge(context)) return tabletLarge!;
    if (tablet != null && responsiveUtils.isTablet(context)) return tablet!;
    return mobile;
  }
}