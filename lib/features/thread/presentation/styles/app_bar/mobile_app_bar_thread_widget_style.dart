
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class MobileAppBarThreadWidgetStyle {
  static const double buttonMaxWidth = 80;
  static const double titleOffset = 180;
  static const double minHeight = 56;

  static const Color backgroundColor = Colors.white;
  static const Color backButtonColor = AppColor.steelGrayA540;

  static EdgeInsetsGeometry getPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 8);
    }
  }
  static const EdgeInsetsGeometry mailboxMenuPadding = EdgeInsets.all(5);
  static const EdgeInsetsGeometry titlePadding = EdgeInsets.symmetric(horizontal: 16);

  static const TextStyle emailCounterTitleStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: AppColor.steelGrayA540,
  );
  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 21,
    color: Colors.black,
    fontWeight: FontWeight.bold
  );
  static Color getFilterButtonColor(FilterMessageOption option) {
    return option == FilterMessageOption.all
      ? AppColor.colorFilterMessageDisabled
      : AppColor.colorFilterMessageEnabled;
  }
}