
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class EmailAttachmentsStyles {
  static const double headerTextSize = 15;
  static const double headerIconSize = 20;
  static const double headerSpace = 8;
  static const double marginHeader = 6;
  static const double buttonTextSize = 16;
  static const double buttonMoreAttachmentsTextSize = 14;
  static const double buttonBorderRadius = 8;
  static const double listSpace = 8;

  static const Color headerTextColor = AppColor.colorTitleHeaderAttachment;
  static const Color headerIconColor = AppColor.colorAttachmentIcon;
  static const Color buttonTextColor = AppColor.colorTextBody;
  static const Color buttonMoreAttachmentsTextColor = AppColor.colorLabelMoreAttachmentsButton;

  static const FontWeight headerFontWeight = FontWeight.w400;
  static const FontWeight buttonFontWeight = FontWeight.w400;
  static const FontWeight buttonMoreAttachmentsFontWeight = FontWeight.w500;

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.only(start: 16, end: 16, bottom: 12);
  static const EdgeInsetsGeometry buttonPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 12);
  static const EdgeInsetsGeometry moreButtonMargin = EdgeInsetsDirectional.only(bottom: 2, start: 8);
  static const attachmentsInfoPadding = EdgeInsetsDirectional.only(end: 8);
}