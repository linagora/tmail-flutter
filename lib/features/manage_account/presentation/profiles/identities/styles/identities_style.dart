import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class IdentitiesStyle {
  static EdgeInsetsGeometry getPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  static EdgeInsetsGeometry getListViewPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsetsDirectional.only(start: 40, end: 40, bottom: 8);
    } else if (responsiveUtils.isMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
  }
}