
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:model/mailbox/select_mode.dart';

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

  static EdgeInsetsGeometry getMobilePaddingItemList({
    required BuildContext context,
    required ResponsiveUtils responsiveUtils,
    SelectMode? selectMode
  }) {
    if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeTablet(context)) {
      return EdgeInsets.symmetric(
        horizontal: selectMode == SelectMode.ACTIVE ? 8 : 16
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: selectMode == SelectMode.ACTIVE ? 24 : 32
      );
    }
  }

  static EdgeInsetsGeometry getMobilePaddingDivider({
    required BuildContext context,
    required ResponsiveUtils responsiveUtils,
    SelectMode? selectMode
  }) {
    if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeTablet(context)) {
      return EdgeInsets.symmetric(
        horizontal: 16,
        vertical: selectMode == SelectMode.ACTIVE ? 2 : 0.0
      );
    } else {
      return EdgeInsets.symmetric(
        horizontal: 32,
        vertical: selectMode == SelectMode.ACTIVE ? 2 : 0.0
      );
    }
  }

  static EdgeInsetsGeometry getPaddingDividerWeb(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isDesktop(context)) {
      return const EdgeInsetsDirectional.only(start: 120, top: 2);
    }else if (responsiveUtils.isTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 24);
    } else {
      return const EdgeInsets.symmetric(horizontal: 12);
    }
  }
}