
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';

class SearchEmailUtils {
  static EdgeInsets getPaddingAppBar(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else {
      if (responsiveUtils.isScreenWithShortestSide(context)) {
        return const EdgeInsets.symmetric(horizontal: 10);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32);
      }
    }
  }

  static EdgeInsets getPaddingSearchSuggestionList(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb || !responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  static EdgeInsets getPaddingShowAllResultButton(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb || !responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  static EdgeInsets getPaddingSearchRecentTitle(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb || !responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    }
  }

  static EdgeInsets getPaddingListRecentSearch(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb || !responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
    }
  }

  static EdgeInsets getPaddingSearchFilterButton(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb || !responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsets.all(12);
    } else {
      return const EdgeInsets.symmetric(vertical: 12, horizontal: 16);
    }
  }

  static EdgeInsets getMarginSearchFilterButton(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb || !responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsets.symmetric(horizontal: 20);
    } else {
      return EdgeInsets.zero;
    }
  }

  static EdgeInsets getPaddingSearchResultList(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb) {
      return const EdgeInsets.only(left: 10);
    } else {
      if (responsiveUtils.isScreenWithShortestSide(context)) {
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 5);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 5);
      }
    }
  }

  static EdgeInsets getPaddingDividerSearchResultList(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb) {
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