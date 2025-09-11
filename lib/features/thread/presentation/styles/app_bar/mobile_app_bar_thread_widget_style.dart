
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class MobileAppBarThreadWidgetStyle {
  static const double buttonMaxWidth = 80;
  static const double titleOffset = 180;
  static const double height = 52;
  static const double actionIconSize = 20;

  static const Color backgroundColor = Colors.white;
  static const Color actionIconColor = AppColor.steelGrayA540;
  static const Color actionIconActiveColor = AppColor.primaryMain;

  static EdgeInsetsGeometry getPadding(
    BuildContext context,
    ResponsiveUtils responsiveUtils,
  ) {
    if (responsiveUtils.isPortraitMobile(context) ||
        responsiveUtils.isLandscapeTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32);
    }
  }

  static const EdgeInsetsGeometry mailboxMenuPadding = EdgeInsets.all(5);
  static const EdgeInsetsGeometry titlePadding = EdgeInsets.symmetric(horizontal: 16);

  static TextStyle emailCounterTitleStyle = ThemeUtils.textStyleBodyBody2(
    color: AppColor.steelGrayA540,
  );
  static TextStyle titleTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 21,
    color: Colors.black,
    fontWeight: FontWeight.bold,
  );
  static Color getFilterButtonColor(FilterMessageOption option) {
    return option == FilterMessageOption.all
      ? AppColor.colorFilterMessageDisabled
      : AppColor.colorFilterMessageEnabled;
  }
}