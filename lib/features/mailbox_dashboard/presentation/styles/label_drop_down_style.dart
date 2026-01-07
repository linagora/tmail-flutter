import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class LabelDropDownStyle {
  static const int dropdownElevation = 0;

  static const double height = 48;
  static const double dropdownMaxHeight = 210;
  static const double scrollbarThickness = 6;
  static const double checkedIconSize = 20;

  static final Color unCheckedIconColor =
      AppColor.gray424244.withValues(alpha: 0.72);
  static const Color checkedIconColor = AppColor.primaryMain;

  static const Offset dropdownOffset = Offset(0.0, -3.0);

  static BoxDecoration dropdownDecoration = BoxDecoration(
    borderRadius: const BorderRadius.all(Radius.circular(16)),
    color: Colors.white,
    border: Border.all(color: AppColor.m3Tertiary60),
    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 24)],
  );

  static const EdgeInsetsGeometry buttonPadding = EdgeInsetsDirectional.only(
    start: 12,
    end: 8,
  );
  static const EdgeInsetsGeometry dropdownPadding = EdgeInsets.all(12);
  static const MenuItemStyleData menuItemStyleData = MenuItemStyleData(
    height: height,
    padding: EdgeInsets.symmetric(horizontal: 12),
  );

  static const Radius dropdownScrollbarRadius = Radius.circular(40);

  static TextStyle menuItemStyle = ThemeUtils.textStyleBodyBody3(
    color: Colors.black,
  );
}
