
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AttachmentItemWidgetStyle {
  static const double radius = 8;
  static const double mobileWidth = 224;
  static const double width = 260;
  static const double height = 36;
  static const double iconSize = 20;
  static const double space = 8;
  static const double downloadIconSize = 20;
  static const double attachmentNameMaxWidth = 130;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.only(end: 0);
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