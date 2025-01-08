import 'package:core/presentation/extensions/color_extension.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';

class FromComposerDropDownWidgetStyle {
  static const double space = 8.0;
  static const double dropdownItemSpace = 12.0;
  static const double avatarSize = 48.0;
  static const double avatarBorderWidth = 0.5;
  static const double dropdownTopBarHeight = 32.0;
  static const double buttonHeight = 32.0;
  static const double buttonWidth = 411.0;

  static const EdgeInsetsGeometry prefixPadding = EdgeInsetsDirectional.only(top: 16.0);
  static const EdgeInsetsGeometry editIdentityIconPadding = EdgeInsets.all(5.0);
  static const EdgeInsetsGeometry dropdownButtonPadding = EdgeInsets.symmetric(vertical: 8.0);
  static const EdgeInsetsGeometry dropdownItemPadding = EdgeInsets.symmetric(vertical: 12.0);
  static const EdgeInsetsGeometry dropdownTopBarPadding = EdgeInsets.only(
    top: 12.0,
    left: 20.0,
    right: 20.0,
  );
  static const EdgeInsetsGeometry buttonPadding = EdgeInsets.only(
    top: 4.0,
    bottom: 4.0,
    right: 4.0,
    left: 8.0,
  );

  static const editIdentityIconBorderRadius = BorderRadius.all(Radius.circular(12.0));

  static const BoxDecoration buttonDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(10.0)),
    color: AppColor.colorComposerAppBar,
  );

  static const ButtonStyleData buttonStyleData = ButtonStyleData(
    width: buttonWidth,
    height: buttonHeight,
    padding: buttonPadding,
    decoration: buttonDecoration,
  );
  static DropdownStyleData dropdownStyleData = DropdownStyleData(
    maxHeight: 272.0,
    decoration: const BoxDecoration(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      color: Colors.white,
    ),
    width: 381.0,
    elevation: 4,
    offset: const Offset(0.0, -8.0),
    scrollbarTheme: ScrollbarThemeData(
      radius: const Radius.circular(40.0),
      thickness: WidgetStateProperty.all<double>(6.0),
      thumbVisibility: WidgetStateProperty.all<bool>(true),
    )
  );
  static MenuItemStyleData menuIemStyleData = MenuItemStyleData(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    height: 72,
    overlayColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) => Colors.white)
  );
  static const TextStyle avatarTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.black,
  );
  static const TextStyle dropdownItemTitleTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColor.colorDropDownItemTitleComposer,
  );
  static const TextStyle dropdownItemSubTitleTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColor.colorLabelQuotas
  );
  static const TextStyle dropdownTitleTextStyle = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColor.colorDropDownTitleComposer,
  );
  static const TextStyle dropdownButtonTitleTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColor.colorCalendarEventUnread
  );
  static const TextStyle dropdownButtonSubTitleTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColor.colorLabelComposer
  );
}