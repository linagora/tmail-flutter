
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/cupertino.dart';

class SendingQueueUtils {

  static EdgeInsets getPaddingAppBarByResponsiveSize(double width) {
    if (ResponsiveUtils.isMatchedMobileWidth(width)) {
      return const EdgeInsets.symmetric(horizontal: 10);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
  }

  static EdgeInsets getMarginBannerMessageByResponsiveSize(double width) {
    if (ResponsiveUtils.isMatchedMobileWidth(width)) {
      return const EdgeInsets.only(top: 16, left: 16, right: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }

  static EdgeInsets getPaddingItemListViewByResponsiveSize(double width) {
    if (ResponsiveUtils.isMatchedMobileWidth(width)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 8);
    }
  }

  static EdgeInsets getPaddingDividerListViewByResponsiveSize(double width) {
    if (ResponsiveUtils.isMatchedMobileWidth(width)) {
      return const EdgeInsets.only(left: 84, right: 8, top: 8);
    } else {
      return const EdgeInsets.only(left: 100, right: 24, top: 8);
    }
  }
}