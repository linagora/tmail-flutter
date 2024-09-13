
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class SearchEmailUtils {
  static EdgeInsets getPaddingItemListMobile(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }
}