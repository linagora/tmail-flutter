import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class MailboxVisibilityUtils {
  static EdgeInsets getPaddingListView(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsets.all(8);
    } else if (responsiveUtils.isMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 8);
    }
  }
}