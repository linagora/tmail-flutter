import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class EmptyMailboxDialogOverlayStyles {
  static const double width = 300;
  static const double radius = 16;
  static const double closeButtonIconSize = 28;
  static const double space = 12;
  static const double buttonSpace = 9;
  static const double buttonRadius = 8;
  static const double elevation = 8;

  static const EdgeInsetsGeometry margin = EdgeInsetsDirectional.only(start: 12);
  static const EdgeInsetsGeometry padding = EdgeInsets.all(12);
  static const EdgeInsetsGeometry iconPadding = EdgeInsets.zero;
  static const EdgeInsetsGeometry buttonPadding = EdgeInsets.symmetric(vertical: 8, horizontal: 12);
  static const EdgeInsetsGeometry emptyButtonPadding = EdgeInsetsDirectional.symmetric(vertical: 2, horizontal: 5);

  static const Color backgroundColor = Colors.white;
  static const Color closeButtonColor = AppColor.colorClosePopupDialogButton;
  static const Color cancelButtonColor = AppColor.colorCancelPopupDialogButton;
  static const Color emptyButtonColor = AppColor.colorEmptyPopupDialogButton;
  static const Color emptyButtonBackground = Colors.transparent;
  static Color get shadowColor => Colors.grey.shade500;

  static const TextStyle titleTextStyle = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: Colors.black
  );
  static const TextStyle messageTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black
  );
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.black
  );
  static const TextStyle emptyButtonTextStyle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: AppColor.colorTextBody
  );
}