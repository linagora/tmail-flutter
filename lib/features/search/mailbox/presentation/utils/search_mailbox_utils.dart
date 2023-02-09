import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class SearchMailboxUtils {
  static EdgeInsets getPaddingAppBar(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
    } else {
      if (responsiveUtils.isScreenWithShortestSide(context)) {
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      } else {
        return const EdgeInsets.symmetric(horizontal: 28, vertical: 8);
      }
    }
  }

  static EdgeInsets getPaddingInputSearchIcon(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsets.only(left: 5, right: 2);
    } else {
      if (responsiveUtils.isScreenWithShortestSide(context)) {
        return const EdgeInsets.only(left: 6, right: 14);
      } else {
        return const EdgeInsets.only(left: 8, right: 16);
      }
    }
  }

  static double getIconSize(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return 30;
    } else {
      return 40;
    }
  }

  static double getIconSplashRadius(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return 10;
    } else {
      return 15;
    }
  }

  static EdgeInsets getPaddingListViewMailboxSearched(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsets.only(left: 16, right: 16, bottom: 16);
    } else {
      if (responsiveUtils.isScreenWithShortestSide(context)) {
        return const EdgeInsets.all(16);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
      }
    }
  }

  static EdgeInsets getPaddingItemListView(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsets.all(8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 10);
    }
  }
}