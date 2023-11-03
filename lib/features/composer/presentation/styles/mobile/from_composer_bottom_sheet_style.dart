import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class FromComposerBottomSheetStyle {
  static const double space = 8.0;
  static const double searchIconSize = 14.0;
  static const double searchBarBottomSpace = 24.0;
  static const double scrollbarThickness = 8.0;
  static const double identityItemSize = 48.0;
  static const double identityItemBorderWidth = 0.5;
  static const double identityItemSpace = 12.0;

  static const EdgeInsetsGeometry closeButtonPadding = EdgeInsets.all(16.0);
  static const EdgeInsetsGeometry bodyPadding = EdgeInsets.symmetric(horizontal: 12.0);
  static const EdgeInsetsGeometry searchTextInputPadding = EdgeInsets.all(12.0);

  static const Color barrierColor = AppColor.colorDefaultCupertinoActionSheet;
  static const Color searchIconColor = AppColor.loginTextFieldHintColor;
  
  static const BorderRadius backgroundBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(14),
    topRight: Radius.circular(14),
  );
  static const Radius radius = Radius.circular(10.0);
  static const BorderRadius borderRadius  = BorderRadius.all(radius);

  static const BoxDecoration searchBarDecoration = BoxDecoration(
    borderRadius: BorderRadius.all(Radius.circular(10)),
    color: AppColor.colorBgSearchBar
  );

  static const TextStyle appBarTitleTextStyle = TextStyle(
    color: Colors.black,
    fontWeight: FontWeight.w700,
    fontSize: 20.0,
  );
  static const TextStyle searchBarTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
  );
  static const TextStyle searchHintTextStyle = TextStyle(
    color: AppColor.loginTextFieldHintColor,
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
  );
  static const TextStyle identityItemTitleTextStyle = TextStyle(
    color: Colors.black,
    fontSize: 16.0,
    fontWeight: FontWeight.w500,
  );
  static const TextStyle identityItemSubTitleTextStyle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColor.colorLabelQuotas
  );
}