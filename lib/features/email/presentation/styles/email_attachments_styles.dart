
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class EmailAttachmentsStyles {
  static const double headerTextSize = 15;
  static const double headerIconSize = 20;
  static const double headerSpace = 4;
  static const double marginHeader = 6;
  static const double buttonTextSize = 13;
  static const double buttonBorderRadius = 8;
  static const double listSpace = 12;
  static const double listHeight = 60;

  static const Color headerTextColor = AppColor.colorTitleHeaderAttachment;
  static const Color headerIconColor = AppColor.colorAttachmentIcon;
  static const Color buttonTextColor = AppColor.primaryColor;

  static const FontWeight headerFontWeight = FontWeight.w400;
  static const FontWeight buttonFontWeight = FontWeight.w400;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.symmetric(vertical: 12, horizontal: 16);
  static const EdgeInsetsGeometry buttonPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 12);
}