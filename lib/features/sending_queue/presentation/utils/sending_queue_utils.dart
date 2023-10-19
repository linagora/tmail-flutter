
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/cupertino.dart';

class SendingQueueUtils {



  static EdgeInsets getMarginBannerMessageByResponsiveSize(double width) {
    if (ResponsiveUtils.isMatchedMobileWidth(width)) {
      return const EdgeInsets.only(top: 16, left: 16, right: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 16);
    }
  }
}