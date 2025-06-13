import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class SortByDropdownStyle {
  static const int dropdownElevation = 4;
  
  static const double height = 44;
  static const double dropdownMaxHeight = 332;
  static const double scrollbarThickness = 6;
  static const double checkedIconSize = 20;

  static const Offset dropdownOffset = Offset(0.0, -8.0);

  static const BoxDecoration dropdownDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    color: Colors.white
  );

  static const EdgeInsetsDirectional buttonPadding = EdgeInsetsDirectional.only(start: 12, end: 8);
  static const MenuItemStyleData menuItemStyleData = MenuItemStyleData(
    height: height,
    padding: EdgeInsets.symmetric(horizontal: 12),
  );

  static const Radius dropdownScrollbarRadius = Radius.circular(40);
}