import 'package:core/presentation/utils/theme_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class DateSelectionDropdownButtonStyles {
  static const double height = 44.0;
  static const double borderWidth = 0.5;
  static const double dropdownMaxHeight = 200.0;
  static const double scrollbarThickness = 6.0;
  static const double checkedIconSize = 20.0;

  static const int dropdownElevation = 4;

  static const Offset dropdownOffset = Offset(0.0, -8.0);

  static const EdgeInsetsGeometry padding = EdgeInsetsDirectional.only(
    start: 12,
    end: 10
  );

  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(10));

  static const Radius scrollbarRadius = Radius.circular(40);

  static const BoxDecoration dropdownDecoration = BoxDecoration(
    borderRadius: borderRadius,
    color: Colors.white,
  );

  static TextStyle selectedValueTexStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );

  static const MenuItemStyleData menuItemStyleData = MenuItemStyleData(
    height: height,
    padding: EdgeInsets.symmetric(horizontal: 12),
  );
}