
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class QuotasBannerStyles {
  static const double iconPadding = 16;
  static const double iconSize = 32;
  static const double titleTextSize = 17;
  static const double messageTextSize = 15;
  static const double space = 4;
  static const double borderRadius = 12;

  static const Color messageTextColor = AppColor.steelGray400;

  static const FontWeight titleFontWeight = FontWeight.w700;
  static const FontWeight messageFontWeight = FontWeight.w400;

  static const EdgeInsetsGeometry bannerPadding = EdgeInsetsDirectional.symmetric(
    horizontal: 16,
    vertical: 8,
  );
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