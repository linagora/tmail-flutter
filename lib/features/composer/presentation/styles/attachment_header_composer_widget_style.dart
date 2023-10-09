import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AttachmentHeaderComposerWidgetStyle {
  static const double space = 8;
  static const double iconSize = 20;
  static const double sizeLabelRadius = 12;

  static const Color iconColor = AppColor.colorLabelComposer;
  static const Color sizeLabelBackground = AppColor.primaryColor;
  static const Color borderColor = AppColor.colorLineComposer;

  static const EdgeInsetsGeometry sizeLabelPadding = EdgeInsetsDirectional.symmetric(horizontal: 5, vertical: 2);
  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.all(8);

  static const TextStyle labelTextSize = TextStyle(
    fontSize: 13,
    color: AppColor.colorLabelComposer,
    fontWeight: FontWeight.w500
  );
  static const TextStyle sizeLabelTextSize = TextStyle(
    fontSize: 12,
    color: Colors.white,
    fontWeight: FontWeight.w500
  );
}