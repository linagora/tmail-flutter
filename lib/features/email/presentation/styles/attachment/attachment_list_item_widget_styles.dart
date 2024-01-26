
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AttachmentListItemWidgetStyle {
  static const double iconSize = 44;
  static const double space = 8;
  static const double downloadIconSize = 24;
  static const double fileTitleBottomSpace = 4;

  static const EdgeInsetsGeometry contentPadding = EdgeInsetsDirectional.all(12);

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
}