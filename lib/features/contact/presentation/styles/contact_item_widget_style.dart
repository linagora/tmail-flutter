
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class ContactItemWidgetStyle {
  static const TextStyle nameAddressTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 15,
    fontWeight: FontWeight.w600
  );

  static const TextStyle emailAddressTextStyle = TextStyle(
    color: AppColor.colorSubtitle,
    fontSize: 13,
    fontWeight: FontWeight.w400
  );

  static EdgeInsetsGeometry getItemPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    if (PlatformInfo.isWeb || responsiveUtils.isScreenWithShortestSide(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 10);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 10);
    }
  }
}