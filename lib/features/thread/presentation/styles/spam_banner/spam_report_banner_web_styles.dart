
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class SpamReportBannerWebStyles {
  static const double borderRadius = 12;
  static Color backgroundColor = AppColor.colorSpamReportBannerBackground.withValues(alpha: 0.12);
  static const Color strokeBorderColor = AppColor.colorSpamReportBannerStrokeBorder;

  static const EdgeInsetsGeometry bannerPadding = EdgeInsetsDirectional.symmetric(
    horizontal: 16,
    vertical: 8);
  static const EdgeInsetsGeometry bannerMargin = EdgeInsetsDirectional.only(
    end: 16,
    bottom: 8);
}