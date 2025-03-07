
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AttachmentItemWidgetStyle {
  static const double radius = 8;
  static const double maxWidthMobile = 260;
  static const double maxWidthTablet = 240;
  static const double maxWidthTabletLarge = 200;
  static const double height = 36;
  static const double iconSize = 20;
  static const double space = 8;
  static const double downloadIconSize = 22;

  static const EdgeInsetsGeometry contentPadding = EdgeInsetsDirectional.symmetric(horizontal: 8, vertical: 5);

  static const Color borderColor = AppColor.attachmentFileBorderColor;

  static const TextStyle labelTextStyle = TextStyle(
    fontSize: 14,
    color: AppColor.attachmentFileNameColor,
    fontWeight: FontWeight.w500
  );
  static const TextStyle dotsLabelTextStyle = TextStyle(
    fontSize: 12,
    color: AppColor.attachmentFileNameColor,
    fontWeight: FontWeight.w500
  );
  static const TextStyle sizeLabelTextStyle = TextStyle(
    fontSize: 12,
    color: AppColor.attachmentFileSizeColor,
    fontWeight: FontWeight.normal
  );

  static double getMaxWidthItem({
    required bool platformIsMobile,
    required bool responsiveIsMobile,
    required bool responsiveIsTablet,
    required bool responsiveIsTabletLarge,
  }) {
    if (platformIsMobile) {
      return responsiveIsMobile ? maxWidthMobile : maxWidthTablet;
    } else {
      if (responsiveIsTabletLarge) {
        return maxWidthTabletLarge;
      } else if (responsiveIsTablet) {
        return maxWidthTablet;
      } else {
        return maxWidthMobile;
      }
    }
  }
}