
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';

class EmailViewBottomBarWidgetStyles {
  static const double topBorderWidth = 0.5;
  static const double buttonRadius = 0;
  static const double buttonIconSize = 20;
  static const double radius = 20;

  static const Color iconColor = AppColor.steelGrayA540;
  static const Color topBorderColor = AppColor.colorDividerHorizontal;
  static const Color backgroundColor = Colors.white;
  static const Color buttonBackgroundColor =  Colors.transparent;

  static const EdgeInsetsGeometry buttonPadding = EdgeInsets.symmetric(horizontal: 8, vertical: 12);
  static EdgeInsetsGeometry? get padding {
    if (PlatformInfo.isIOS) {
      return const EdgeInsetsDirectional.only(bottom: 30);
    } else {
      return null;
    }
  }

  static TextStyle getButtonTextStyle(
    BuildContext context,
    ResponsiveUtils responsiveUtils
  ) {
    return TextStyle(
      fontSize: responsiveUtils.isPortraitMobile(context) ? 12 : 16,
      color: EmailViewBottomBarWidgetStyles.iconColor,
    );
  }
}