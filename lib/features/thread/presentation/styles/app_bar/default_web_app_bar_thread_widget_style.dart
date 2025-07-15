
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class DefaultWebAppBarThreadWidgetStyle {
  static const double buttonMaxWidth = 80;
  static const double titleOffset = 180;
  static const double minHeight = 56;

  static const Color backgroundColor = Colors.white;

  static EdgeInsetsGeometry getPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isMobile(context) || responsiveUtils.isTabletLarge(context)) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 24, vertical: 8);
    }
  }
  static const EdgeInsetsGeometry mailboxMenuPadding = EdgeInsets.all(5);
  static const EdgeInsetsGeometry titlePadding = EdgeInsets.symmetric(horizontal: 16);

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