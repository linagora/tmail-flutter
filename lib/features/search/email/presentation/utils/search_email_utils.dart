
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class SearchEmailUtils {
  static EdgeInsets getPaddingAppBar(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb) {
      if (responsiveUtils.isMobile(context)) {
        return const EdgeInsets.symmetric(horizontal: 16);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32);
      }
    } else {
      if (responsiveUtils.isPortraitMobile(context)) {
        return const EdgeInsets.symmetric(horizontal: 8);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32);
      }
    }
  }

  static EdgeInsets getPaddingSearchSuggestionList(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb || !responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  static EdgeInsets getPaddingShowAllResultButton(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb || !responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  static EdgeInsets getPaddingSearchRecentTitle(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb || !responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  static EdgeInsets getPaddingListRecentSearch(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb || !responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  static EdgeInsets getPaddingSearchFilterButton(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb) {
      return const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    } else {
      if (responsiveUtils.isPortraitMobile(context)) {
        return const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
      } else {
        return const EdgeInsets.symmetric(vertical: 12, horizontal: 32);
      }
    }
  }

  static EdgeInsets getPaddingItemListMobile(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  static EdgeInsets getMarginSearchFilterButton(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb) {
      return const EdgeInsets.symmetric(horizontal: 20);
    } else {
      return EdgeInsets.zero;
    }
  }

  static EdgeInsetsGeometry getPaddingSearchResultList(BuildContext context, ResponsiveUtils responsiveUtils) {
    return const EdgeInsetsDirectional.only(top: 8, bottom: 8, end: 8);
  }

  static EdgeInsets getPaddingDividerSearchResultList(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else {
      if (responsiveUtils.isScreenWithShortestSide(context)) {
        return const EdgeInsets.symmetric(horizontal: 16);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32);
      }
    }
  }
}