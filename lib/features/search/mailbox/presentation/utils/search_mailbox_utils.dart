import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class SearchMailboxUtils {
  static EdgeInsets getPaddingAppBar(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsets.symmetric(vertical: 8, horizontal: 16);
    } else {
      if (responsiveUtils.isScreenWithShortestSide(context)) {
        return const EdgeInsets.symmetric(horizontal: 10);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32);
      }
    }
  }
}