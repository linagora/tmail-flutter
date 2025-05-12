
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/icon_utils.dart';
import 'package:flutter/material.dart';

class EmailViewStyles {
  static const double mobileContentHorizontalMargin = 16;
  static const double mobileContentVerticalMargin = 12;
  static double pageViewIconSize = IconUtils.defaultIconSize;
  static const double initialHtmlViewHeight = 200;

  static const Color iconColor = AppColor.steelGrayA540;

  static const EdgeInsetsGeometry emailContentPadding =
    EdgeInsetsDirectional.only(
      start: 16,
      bottom: 16,
      end: 16,
      top: 8,
    );
}