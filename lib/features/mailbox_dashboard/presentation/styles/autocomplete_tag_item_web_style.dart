import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AutoCompleteTagItemWebStyle {
  static const double paddingTop = 3.0;
  static const double paddingEnd = 40.0;
  static const double labelPaddingHorizontal = 4.0;
  static const EdgeInsetsGeometry collapsedPadding = EdgeInsetsDirectional.symmetric(vertical: 4, horizontal: 8);

  static const EdgeInsetsGeometry marginCollapsed = EdgeInsets.only(top: 3);

  static const BorderRadius shapeBorderRadius = BorderRadius.all(Radius.circular(10.0));

  static const Color collapsedBackgroundColor = AppColor.colorEmailAddressTag;

  static const TextStyle labelTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 17,
    fontWeight: FontWeight.w400
  );
  static const TextStyle collapsedTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 17,
    fontWeight: FontWeight.w400
  );
}