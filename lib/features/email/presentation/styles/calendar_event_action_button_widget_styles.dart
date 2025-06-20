
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class CalendarEventActionButtonWidgetStyles {
  static const double borderRadius = 10;
  static const double textSize = 16;
  static const double space = 16;
  static const double borderWidth = 1;
  static const double minWidth = 80;

  static const Color backgroundColor = Colors.transparent;
  static Color loadingBackgroundColor = Colors.grey.shade300;
  static const Color selectedBackgroundColor = AppColor.disableSendEmailButtonColor;
  static const Color selectedTextColor = Colors.white;
  static const Color textColor = AppColor.primaryColor;

  static const FontWeight fontWeight = FontWeight.w500;

  static const EdgeInsetsGeometry buttonPadding = EdgeInsetsDirectional.symmetric(vertical: 8, horizontal: 12);
  static const EdgeInsetsGeometry paddingMobile = EdgeInsetsDirectional.only(top: 16);
  static const EdgeInsetsGeometry paddingWeb = EdgeInsetsDirectional.only(start: 100, end: 16, top: 16);
}