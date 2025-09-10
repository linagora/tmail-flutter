
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class QuotasBannerStyles {
  static const double iconPadding = 16;
  static const double iconSize = 32;
  static const double titleTextSize = 15;
  static const double borderRadius = 8;

  static const Color messageTextColor = AppColor.steelGray400;
  static const Color backgroundColor = AppColor.lightGrayEAEDF2;

  static const FontWeight messageFontWeight = FontWeight.w400;

  static TextStyle titleTextStyle = ThemeUtils.textStyleInter500().copyWith(
    fontSize: 15,
    height: 20 / 15,
    letterSpacing: 0.0,
    color: Colors.black,
  );
  static TextStyle subTitleTextStyle = ThemeUtils.textStyleInter400.copyWith(
    fontSize: 13,
    height: 16 / 13,
    letterSpacing: 0.0,
    color: AppColor.steelGray400,
  );
  static TextStyle manageStorageButtonTextStyle = ThemeUtils.textStyleInter700().copyWith(
    fontSize: 14,
    height: 20 / 14,
    letterSpacing: 0.0,
    color: AppColor.blue700,
  );

  static const EdgeInsetsGeometry bannerPadding = EdgeInsetsDirectional.only(
    start: 16,
    end: 40,
    top: 12,
    bottom: 12,
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