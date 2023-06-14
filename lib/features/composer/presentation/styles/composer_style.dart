
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/cupertino.dart';

class ComposerStyle {

  static const double radius = 24;

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

  static EdgeInsetsGeometry getToAddressPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb) {
      if (responsiveUtils.isMobile(context)) {
        return const EdgeInsetsDirectional.only(start: 16, end: 8);
      } else {
        return const EdgeInsetsDirectional.symmetric(horizontal: 8);
      }
    } else {
      if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
        return const EdgeInsetsDirectional.symmetric(horizontal: 16);
      } else {
        return const EdgeInsetsDirectional.only(start: 8, end: 16);
      }
    }
  }

  static EdgeInsetsGeometry getCcBccAddressPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb) {
      if (responsiveUtils.isMobile(context)) {
        return const EdgeInsetsDirectional.only(start: 16);
      } else {
        return const EdgeInsetsDirectional.symmetric(horizontal: 8);
      }
    } else {
      if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
        return const EdgeInsetsDirectional.only(start: 16);
      } else {
        return const EdgeInsetsDirectional.symmetric(horizontal: 8);
      }
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

  static EdgeInsetsGeometry getPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeMobile(context)) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 8);
    } else {
      return const EdgeInsetsDirectional.symmetric(horizontal: 32);
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
      return const EdgeInsetsDirectional.only(start: 88, end: 48);
    }
  }

  static EdgeInsetsGeometry getRichTextButtonPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isMobile(context)) {
      return const EdgeInsetsDirectional.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsetsDirectional.only(start: 88, end: 48, top: 8, bottom: 8);
    }
  }

  static EdgeInsetsGeometry getEditorPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (PlatformInfo.isWeb) {
      if (responsiveUtils.isMobile(context)) {
        return const EdgeInsetsDirectional.symmetric(horizontal: 16);
      } else {
        return const EdgeInsetsDirectional.only(start: 88, end: 48);
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

  static EdgeInsetsGeometry getMarginForTabletWeb(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isTablet(context)) {
      return const EdgeInsetsDirectional.all(24);
    } else {
      return const EdgeInsetsDirectional.symmetric(vertical: 24);
    }
  }

  static double getWidthForTabletWeb(BuildContext context, ResponsiveUtils responsiveUtils) {
    final currentWidth = responsiveUtils.getSizeScreenWidth(context);
    if (responsiveUtils.isTablet(context)) {
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