
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';

class ItemEmailTileStyles {

  static const double avatarIconSize = 60.0;
  static const double horizontalTitleGap = 8.0;

  static EdgeInsetsGeometry getSpaceCalendarEventIcon(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsetsDirectional.only(end: 4);
    } else if (responsiveUtils.isWebDesktop(context)) {
      return const EdgeInsetsDirectional.only(end: 12);
    } else {
      return const EdgeInsetsDirectional.only(end: 8);
    }
  }

  static EdgeInsetsGeometry getPaddingItemList(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb) {
      if (responsiveUtils.isDesktop(context)) {
        return const EdgeInsetsDirectional.only(start: 120);
      } else if (responsiveUtils.isMobile(context) || responsiveUtils.isTabletLarge(context)) {
        return const EdgeInsets.symmetric(horizontal: 16);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32);
      }
    } else {
      if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeTablet(context)) {
        return const EdgeInsets.symmetric(horizontal: 16);
      } else {
        return const EdgeInsets.symmetric(horizontal: 32);
      }
    }
  }

  static EdgeInsetsGeometry getPaddingDividerWeb(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isDesktop(context)) {
      return const EdgeInsetsDirectional.only(start: 120);
    } else if (responsiveUtils.isMobile(context) || responsiveUtils.isTabletLarge(context)) {
      return const EdgeInsets.symmetric(horizontal: 12);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24);
    }
  }
}