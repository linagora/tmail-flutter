
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/icon_utils.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class EmailViewAppBarWidgetStyles {
  static const double bottomBorderWidth = 0.5;
  static const double height = 52;
  static const double radius = 20;
  static const double buttonIconSize = IconUtils.defaultIconSize;
  static const double deleteButtonIconSize = 20;
  static const double space = 5;
  static double? heightIOS(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isLandscapeMobile(context)) {
      return 60;
    } else {
      return null;
    }
  }
  static const Color bottomBorderColor = AppColor.colorDividerHorizontal;
  static const Color backgroundColor = Colors.white;
  static const Color emptyTrashButtonColor = AppColor.primaryColor;
  static const Color deletePermanentButtonColor = AppColor.colorDeletePermanentlyButton;
  static const Color buttonActivatedColor = AppColor.primaryColor;
  static const Color buttonDeactivatedColor = AppColor.colorAttachmentIcon;

  static EdgeInsetsGeometry paddingIOS(BuildContext context, ResponsiveUtils responsiveUtils) {
    if (responsiveUtils.isLandscapeMobile(context)) {
      return EdgeInsets.zero;
    } else if (responsiveUtils.isPortraitTablet(context) || responsiveUtils.isLandscapeTablet(context)) {
      return const EdgeInsetsDirectional.only(top: 40, start: 16, end: 16, bottom: 4);
    } else {
      return const EdgeInsetsDirectional.only(top: 60, start: 16, end: 16, bottom: 4);
    }
  }
  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.symmetric(horizontal: 16);
  static const EdgeInsetsGeometry buttonPadding = EdgeInsets.all(5);
}