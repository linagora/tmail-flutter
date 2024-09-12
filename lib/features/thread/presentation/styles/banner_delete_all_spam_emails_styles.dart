
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class BannerDeleteAllSpamEmailsStyles {
  static const double borderRadius = 14;
  static const double buttonBorderRadius = 20;
  static const double horizontalPadding = 16;
  static const double verticalPadding = 10;
  static const double labelTextSize = 13;
  static const double buttonTextSize = 17;
  static const double iconSize = 20;
  static const double space = 8;
  static const Color backgroundColor = Colors.white;
  static const Color borderStrokeColor = AppColor.colorBorderBodyThread;
  static const Color labelTextColor = AppColor.colorSubtitle;
  static const Color buttonTextColor = AppColor.toastErrorBackgroundColor;

  static EdgeInsetsGeometry getBannerMargin(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if (PlatformInfo.isWeb) {
      if (responsiveUtils.isDesktop(context)) {
        return const EdgeInsetsDirectional.only(end: 16, bottom: 8);
      } else if (responsiveUtils.isTablet(context)) {
        return const EdgeInsetsDirectional.only(bottom: 8, start: 24, end: 24);
      } else {
        return const EdgeInsetsDirectional.only(bottom: 8, start: 12, end: 12);
      }
    } else {
      if (responsiveUtils.isPortraitTablet(context)) {
        return const EdgeInsetsDirectional.only(bottom: 8, start: 32, end: 32);
      } else {
        return const EdgeInsetsDirectional.only(bottom: 8, start: 16, end: 16);
      }
    }
  }
}