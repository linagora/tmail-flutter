import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class SearchMailboxUtils {
  static EdgeInsets getPaddingItemListView(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsets.all(8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 8, vertical: 10);
    }
  }
}