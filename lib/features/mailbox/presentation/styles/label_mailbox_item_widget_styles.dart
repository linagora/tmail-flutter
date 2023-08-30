
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class LabelMailboxItemWidgetStyles {
  static const double labelTeamMailboxTextSize = 16;
  static const double labelFolderTextSize = 15;
  static const double teamMailboxTextSize = 15;

  static const Color labelTeamMailboxTextColor = Colors.black;
  static const Color labelFolderTextColor = AppColor.colorNameEmail;
  static const Color teamMailboxTextColor = AppColor.colorEmailAddressFull;
  static const Color emptyButtonBackground = Colors.transparent;

  static const FontWeight labelTeamMailboxTextFontWeight = FontWeight.bold;
  static const FontWeight labelFolderTextFontWeight = FontWeight.normal;
  static const FontWeight teamMailboxTextFontWeight = FontWeight.w400;

  static const EdgeInsetsGeometry emptyButtonPadding = EdgeInsetsDirectional.symmetric(vertical: 2, horizontal: 5);

  static const TextStyle emptyButtonTextStyle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: AppColor.colorTextBody
  );
}