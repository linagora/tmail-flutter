
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class VacationUtils {
  static EdgeInsets getPaddingView(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isDesktop(context)) {
      return const EdgeInsets.symmetric(vertical: 24, horizontal: 20);
    } else if (responsiveUtils.isTabletLarge(context) || responsiveUtils.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 28, vertical: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 24);
    }
  }
}