
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class EmptyEmailsWidgetStyles {
  static const double mobileIconSize = 160;
  static const double tabletIconSize = 180;
  static const double desktopIconSize = 212;
  static const double labelTextSize = 20;
  static const double messageTextSize = 15;
  static const double createFilterLabelTextSize = 22;
  static const double createFilterButtonTextSize = 17;
  static const double maxWidth = 490;
  static const double createFilterButtonBorderRadius = 10;

  static const FontWeight labelFontWeight = FontWeight.w400;
  static const FontWeight messageFontWeight = FontWeight.w400;
  static const FontWeight createFilterLabelFontWeight = FontWeight.w600;
  static const FontWeight createFilterButtonFontWeight = FontWeight.w500;

  static const Color labelTextColor = Colors.black;
  static const Color messageTextColor = AppColor.colorSubtitle;
  static const Color createFilterButtonTextColor = AppColor.primaryColor;
  static const Color createFilterButtonBackgroundColor = AppColor.colorCreateFiltersButton;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.all(16);
  static const EdgeInsetsGeometry labelPadding = EdgeInsetsDirectional.symmetric(vertical: 12);
  static const EdgeInsetsGeometry createFilterButtonPadding = EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 24);
  static const EdgeInsetsGeometry createFilterButtonMargin = EdgeInsetsDirectional.only(top: 12);
}