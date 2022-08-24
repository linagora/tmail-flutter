import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/widgets.dart';

class SettingsUtils {
  static double getHorizontalPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isMobile(context)) {
      return 17;
    } else {
      return 33;
    }
  }

  static EdgeInsets getPaddingInFirstLevel(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isMobile(context)) {
      return const EdgeInsets.only(left: 16, top: 12, bottom: 12, right: 16);
    } else {
      return const EdgeInsets.only(left: 32, top: 12, bottom: 12, right: 32);
    }
  }
}