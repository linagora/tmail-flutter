import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class MarkMailboxAsReadLoadingBannerStyle {
  const MarkMailboxAsReadLoadingBannerStyle._();

  static EdgeInsetsGeometry getBannerMargin(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isDesktop(context)) {
      return const EdgeInsetsDirectional.only(end: 16, bottom: 8);
    } else {
      return const EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 8);
    }
  }
}