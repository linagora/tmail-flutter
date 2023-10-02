
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AttachmentItemWidgetStyle {
  static const double radius = 10;
  static const double mobileWidth = 224;
  static const double width = 250;
  static const double height = 60;
  static const double iconSize = 44;
  static const double space = 8;
  static const double downloadIconSize = 24;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.only(end: 12);
  static const EdgeInsetsGeometry contentPadding = EdgeInsetsDirectional.all(8);

  static const Color borderColor = AppColor.attachmentFileBorderColor;
  static const Color downloadIconColor = AppColor.primaryColor;

  static const TextStyle labelTextStyle = TextStyle(
    fontSize: 14,
    color: AppColor.attachmentFileNameColor,
    fontWeight: FontWeight.normal
  );
  static const TextStyle dotsLabelTextStyle = TextStyle(
    fontSize: 12,
    color: AppColor.attachmentFileNameColor,
    fontWeight: FontWeight.normal
  );
  static const TextStyle sizeLabelTextStyle = TextStyle(
    fontSize: 12,
    color: AppColor.attachmentFileSizeColor,
    fontWeight: FontWeight.normal
  );
}