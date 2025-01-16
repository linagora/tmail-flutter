
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class ComposerStyle {
  static const double radius = 28;
  static const double keyboardToolBarHeight = 200;
  static const double popupMenuRadius = 8;
  static const double suggestionItemHeight = 60;

  static const Color borderColor = AppColor.colorLineComposer;
  static const Color backgroundEditorColor = Colors.white;
  static const Color richToolbarColor = Colors.white;
  static const Color mobileBackgroundColor = Colors.white;
  static const Color popupItemIconColor = AppColor.steelGrayA540;

  static const EdgeInsetsGeometry richToolbarPadding = EdgeInsetsDirectional.symmetric(horizontal: 24, vertical: 8);
  static const EdgeInsetsGeometry desktopRecipientPadding = EdgeInsetsDirectional.only(end: 24);
  static const EdgeInsetsGeometry desktopRecipientMargin = EdgeInsetsDirectional.only(start: 24);
  static const EdgeInsetsGeometry desktopSubjectMargin = EdgeInsetsDirectional.only(start: 24);
  static const EdgeInsetsGeometry desktopSubjectPadding = EdgeInsetsDirectional.only(end: 24);
  static const EdgeInsetsGeometry desktopEditorPadding = EdgeInsetsDirectional.symmetric(horizontal: 20);
  static const EdgeInsetsGeometry tabletRecipientPadding = EdgeInsetsDirectional.only(end: 24);
  static const EdgeInsetsGeometry tabletRecipientMargin = EdgeInsetsDirectional.only(start: 24);
  static const EdgeInsetsGeometry tabletSubjectMargin = EdgeInsetsDirectional.only(start: 24);
  static const EdgeInsetsGeometry tabletSubjectPadding = EdgeInsetsDirectional.only(end: 24);
  static const EdgeInsetsGeometry tabletEditorPadding = EdgeInsetsDirectional.symmetric(horizontal: 20);
  static const EdgeInsetsGeometry mobileRecipientPadding = EdgeInsetsDirectional.only(end: 16);
  static const EdgeInsetsGeometry mobileRecipientMargin = EdgeInsetsDirectional.only(start: 16);
  static const EdgeInsetsGeometry mobileSubjectMargin = EdgeInsetsDirectional.only(start: 16);
  static const EdgeInsetsGeometry mobileSubjectPadding = EdgeInsetsDirectional.only(end: 16);
  static const EdgeInsetsGeometry mobileEditorPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);
  static const EdgeInsetsGeometry popupItemPadding = EdgeInsetsDirectional.symmetric(horizontal: 12);
  static const EdgeInsetsGeometry insertImageLoadingBarPadding = EdgeInsetsDirectional.only(top: 12);

  static const TextStyle popupItemTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w500
  );

  static const List<BoxShadow> richToolbarShadow = [
    BoxShadow(
      color: AppColor.colorShadowBgContentEmail,
      blurRadius: 24
    ),
    BoxShadow(
      color: AppColor.colorShadowBgContentEmail,
      blurRadius: 2
    ),
  ];

  static EdgeInsetsGeometry getAppBarPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsetsDirectional.only(end: 8);
    } else {
      return const EdgeInsetsDirectional.only(start: 24, end: 32);
    }
  }

  static EdgeInsetsGeometry getFromAddressPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 12);
    } else {
      return const EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 12);
    }
  }

  static EdgeInsetsGeometry getSubjectPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsetsDirectional.only(start: 8, top: 8, bottom: 8, end: 16);
    }
  }

  static EdgeInsetsGeometry getSubjectWebPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isMobile(context)) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 16);
    } else {
      return const EdgeInsetsDirectional.only(start: 8, end: 16);
    }
  }

  static double getAppBarHeight(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
      return 57;
    } else {
      return 65;
    }
  }

  static double getSpace(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
      return 8;
    } else {
      return 12;
    }
  }

  static EdgeInsetsGeometry getAttachmentPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 16);
    } else {
      return const EdgeInsetsDirectional.only(start: 88, end: 48, top: 8);
    }
  }

  static EdgeInsetsGeometry getEditorPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb) {
      if (responsiveUtils.isMobile(context)) {
        return const EdgeInsetsDirectional.symmetric(horizontal: 6);
      } else {
        return const EdgeInsetsDirectional.only(start: 78, end: 38);
      }
    } else {
      if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
        return const EdgeInsetsDirectional.symmetric(horizontal: 16);
      } else {
        return const EdgeInsetsDirectional.only(start: 88, end: 48);
      }
    }
  }

  static EdgeInsetsGeometry getMarginForTablet(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitTablet(context)) {
      return const EdgeInsetsDirectional.all(24);
    } else {
      return const EdgeInsetsDirectional.symmetric(vertical: 24);
    }
  }

  static double getWidthForTablet(BuildContext context, ResponsiveUtils responsiveUtils) {
    final currentWidth = responsiveUtils.getSizeScreenWidth(context);
    if (responsiveUtils.isPortraitTablet(context)) {
      return currentWidth;
    } else {
      return currentWidth * 0.7;
    }
  }

  static int getMaxItemRowListAttachment(BuildContext context, BoxConstraints constraints) {
    if (constraints.maxWidth < ResponsiveUtils.minTabletWidth) {
      return 2;
    } else if (constraints.maxWidth < ResponsiveUtils.minTabletLargeWidth) {
      return 4;
    } else {
      return 5;
    }
  }

  static double getMaxWidthItemListAttachment(BuildContext context, BoxConstraints constraints) {
    return constraints.maxWidth / getMaxItemRowListAttachment(context, constraints);
  }

  static double getMaxHeightEmailAddressWidget(BuildContext context, BoxConstraints constraints, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isDesktop(context)) {
      return constraints.maxHeight > 0 ? constraints.maxHeight * 0.3 : 150.0;
    } else {
      return constraints.maxHeight > 0 ? constraints.maxHeight * 0.4 : 150.0;
    }
  }
}