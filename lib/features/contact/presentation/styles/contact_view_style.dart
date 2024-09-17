
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';

class ContactViewStyle {
  static const double viewMaxHeight = 624.0;
  static const double viewMaxWidth = 558.0;

  static double getContactViewHeight(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if ((PlatformInfo.isWeb && responsiveUtils.isMobile(context)) ||
        (PlatformInfo.isMobile && responsiveUtils.isScreenWithShortestSide(context))
    ) {
      return double.infinity;
    } else if (responsiveUtils.getSizeScreenHeight(context) > ContactViewStyle.viewMaxHeight) {
      return ContactViewStyle.viewMaxHeight;
    } else {
      return double.infinity;
    }
  }

  static double getContactViewWidth(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if ((PlatformInfo.isWeb && responsiveUtils.isMobile(context)) ||
        (PlatformInfo.isMobile && responsiveUtils.isScreenWithShortestSide(context))
    ) {
      return double.infinity;
    } else {
      return ContactViewStyle.viewMaxWidth;
    }
  }

  static bool isAppBarTopBorderSupported(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    return !(PlatformInfo.isWeb || responsiveUtils.isLandscapeMobile(context));
  }

  static BorderRadiusGeometry getContactViewBorderRadius(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if (PlatformInfo.isMobile && responsiveUtils.isLandscapeMobile(context)) {
      return BorderRadius.zero;
    } else if ((PlatformInfo.isWeb && responsiveUtils.isMobile(context)) ||
        (PlatformInfo.isMobile && responsiveUtils.isPortraitMobile(context))
    ) {
      return const BorderRadiusDirectional.only(
        topEnd: Radius.circular(16),
        topStart: Radius.circular(16),
      );
    } else {
      return const BorderRadius.all(Radius.circular(16));
    }
  }
}