
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class FeedbackDraggableAttachmentItemWidgetStyle {
  static const double radius = 8;
  static const double iconSize = 24;
  static const double space = 12;
  static const double maxWidth = 300;

  static const Color backgroundColor = Colors.white;

  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

  static TextStyle labelTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    color: Colors.black,
    fontSize: 16,
    fontWeight: FontWeight.w500,
  );
  static TextStyle dotsLabelTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 12,
    color: Colors.black,
    fontWeight: FontWeight.w500,
  );

  static const List<BoxShadow> shadows = [
    BoxShadow(
      color: AppColor.colorShadowLayerBottom,
      blurRadius: 96,
      offset: Offset.zero
    ),
    BoxShadow(
      color: AppColor.colorShadowLayerTop,
      blurRadius: 2,
      offset: Offset.zero
    ),
  ];
}