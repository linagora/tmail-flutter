
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/thread/domain/model/filter_message_option.dart';

class MobileAppBarThreadWidgetStyle {
  static const double minHeight = 56;

  static EdgeInsetsGeometry getPadding(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isPortraitMobile(context) || responsiveUtils.isLandscapeTablet(context)) {
      return const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
    } else {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 8);
    }
  }

  static Color getFilterButtonColor(FilterMessageOption option) {
    return option == FilterMessageOption.all
      ? AppColor.colorFilterMessageDisabled
      : AppColor.colorFilterMessageEnabled;
  }
}