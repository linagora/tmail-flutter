
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';

class ContactUtils {
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

  static EdgeInsets getPaddingSearchInputForm(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    } else {
      if (responsiveUtils.isScreenWithShortestSide(context)) {
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 10);
      }
    }
  }

  static EdgeInsets getPaddingSearchResultList(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    } else {
      if (responsiveUtils.isScreenWithShortestSide(context)) {
        return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 10);
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

  static bool supportAppBarTopBorder(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (BuildUtils.isWeb || responsiveUtils.isLandscapeMobile(context)) {
      return false;
    }
    return true;
  }

  static double getRadiusBorderAppBarTop(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (supportAppBarTopBorder(context, responsiveUtils)) {
      return 16;
    } else {
      return 0;
    }
  }
}