import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class MobileAttachmentComposerWidgetStyle {
  static const double listItemSpace = 8;

  static const Color backgroundColor = Colors.white;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 16);
  static const EdgeInsetsGeometry showMoreMargin = EdgeInsetsDirectional.only(top: 8);

  static const TextStyle showMoreButtonTextStyle = TextStyle(
    fontSize: 15,
    color: AppColor.primaryColor,
    fontWeight: FontWeight.w500
  );
}