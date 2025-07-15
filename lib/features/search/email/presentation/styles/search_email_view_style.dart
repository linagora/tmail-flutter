
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchEmailViewStyle {
  static const SizedBox searchFilterSizeBoxMargin = SizedBox(width: 8);

  static TextStyle searchRecentTitleStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 13.0,
    color: AppColor.colorTextButtonHeaderThread,
    fontWeight: FontWeight.w500,
  );

  static const EdgeInsetsGeometry listSearchFilterButtonMargin = EdgeInsetsDirectional.only(top: 16);

  static EdgeInsetsGeometry? getAppBarPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if ((PlatformInfo.isWeb && responsiveUtils.isMobile(context)) ||
        (PlatformInfo.isMobile && responsiveUtils.isPortraitMobile(context))) {
      return const EdgeInsets.symmetric(horizontal: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  static EdgeInsetsGeometry getListSearchFilterButtonPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if ((PlatformInfo.isWeb && responsiveUtils.isMobile(context)) ||
        (PlatformInfo.isMobile && responsiveUtils.isPortraitMobile(context))) {
      return const EdgeInsetsDirectional.only(bottom: 10, start: 16, end: 16);
    } else {
      return const EdgeInsetsDirectional.only(bottom: 10, start: 32, end: 32);
    }
  }

  static EdgeInsetsGeometry getSearchRecentTitleMargin(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if ((PlatformInfo.isWeb && responsiveUtils.isMobile(context)) ||
        (PlatformInfo.isMobile && responsiveUtils.isPortraitMobile(context))) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsetsDirectional.symmetric(horizontal: 32, vertical: 8);
    }
  }

  static EdgeInsetsGeometry getPaddingSearchResultList(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if ((PlatformInfo.isWeb && responsiveUtils.isMobile(context)) ||
        (PlatformInfo.isMobile && responsiveUtils.isPortraitMobile(context))) {
      return const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 12);
    } else {
      return const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 24);
    }
  }

  static EdgeInsetsGeometry getListRecentSearchPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if ((PlatformInfo.isWeb && responsiveUtils.isMobile(context)) ||
        (PlatformInfo.isMobile && responsiveUtils.isPortraitMobile(context))) {
      return const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 16);
    } else {
      return const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 32);
    }
  }

  static EdgeInsetsGeometry getShowAllResultButtonPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if ((PlatformInfo.isWeb && responsiveUtils.isMobile(context)) ||
        (PlatformInfo.isMobile && responsiveUtils.isPortraitMobile(context))) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsetsDirectional.symmetric(horizontal: 32, vertical: 8);
    }
  }

  static EdgeInsetsGeometry getSearchSuggestionListPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if ((PlatformInfo.isWeb && responsiveUtils.isMobile(context)) ||
        (PlatformInfo.isMobile && responsiveUtils.isPortraitMobile(context))) {
      return const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 16);
    } else {
      return const EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 32);
    }
  }
}