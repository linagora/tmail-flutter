import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
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
  static const Color emptyButtonColor = AppColor.primaryColor;
  static const Color emptyButtonBackground = Colors.transparent;
  static Color get shadowColor => Colors.grey.shade500;

  static TextStyle titleTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 17,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );
  static TextStyle messageTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );
  static TextStyle buttonTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );
  static TextStyle cleanButtonTextStyle =
      ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontWeight: FontWeight.w400,
    fontSize: 13,
    color: Colors.white,
  );
}