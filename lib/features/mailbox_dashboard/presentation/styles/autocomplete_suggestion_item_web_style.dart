import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class AutoCompleteSuggestionItemWebStyle {
  static const double iconSize = 24.0;

  static const EdgeInsetsGeometry margin = EdgeInsets.all(8.0);

  static const EdgeInsetsGeometry contentPaddingDuplicated = EdgeInsets.symmetric(horizontal: 8.0);
  static const EdgeInsetsGeometry contentPaddingValid = EdgeInsets.symmetric(horizontal: 16.0);

  static const Decoration decoration = BoxDecoration(
    color: AppColor.colorBgMenuItemDropDownSelected,
    borderRadius: BorderRadius.all(Radius.circular(20))
  );
  
  static const TextStyle subTitleTextOriginStyle = TextStyle(
    color: AppColor.colorHintSearchBar,
    fontSize: 13,
    fontWeight: FontWeight.normal
  );
  static const TextStyle subTitleWordSearchStyle = TextStyle(
    color: Colors.black,
    fontSize: 13,
    fontWeight: FontWeight.bold
  );
}