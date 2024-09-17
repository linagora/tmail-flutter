
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class ContactUtils {
  static EdgeInsets getPaddingSearchInputForm(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb) {
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
    if (PlatformInfo.isWeb) {
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