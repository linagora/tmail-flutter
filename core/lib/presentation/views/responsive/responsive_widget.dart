import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class ResponsiveWidget extends StatelessWidget {
  final Widget? largeScreen;
  final Widget mediumScreen;
  final Widget? smallScreen;

  final ResponsiveUtils responsiveUtils;

  const ResponsiveWidget({
    Key? key,
    this.largeScreen,
    required this.mediumScreen,
    this.smallScreen,
    required this.responsiveUtils,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (responsiveUtils.isLargeScreen(context)) {
        return largeScreen ?? mediumScreen;
      } else if (responsiveUtils.isMediumScreen(context)) {
        return mediumScreen;
      } else {
        return smallScreen ?? mediumScreen;
      }
    });
  }
}