import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class RecipientSuggestionItemWidgetStyle {
  static const double radius = 20;
  static const double selectedIconSize = 24;

  static const EdgeInsetsGeometry suggestionDuplicatedMargin = EdgeInsets.all(8.0);
  static const EdgeInsetsGeometry labelPadding = EdgeInsets.symmetric(horizontal: 16.0);

  static const TextStyle labelTextStyle = TextStyle(
    color: AppColor.colorHintSearchBar,
    fontSize: 13,
    fontWeight: FontWeight.normal
  );
  static const TextStyle labelHighlightTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 13,
    fontWeight: FontWeight.bold
  );
}