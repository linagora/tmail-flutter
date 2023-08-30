import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class EmptyMailboxPopupDialogWidgetStyles {
  static const EdgeInsetsGeometry emptyButtonPadding = EdgeInsetsDirectional.symmetric(vertical: 4, horizontal: 10);

  static const Color emptyButtonBackground = Colors.transparent;

  static const TextStyle emptyButtonTextStyle = TextStyle(
    fontWeight: FontWeight.w400,
    fontSize: 15,
    color: AppColor.colorTextBody
  );

  static const Offset dialogOverlayOffset = Offset(0.0, 50.0);
}