import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';

class TextInputFieldWidgetStyles {
  static const double titleWidth = 112.0;
  static const double borderWidth = 1.0;
  static const double suffixIconSize = 8.0;
  static const double space = 12.0;
  static const double spaceMobile = 8.0;
  
  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(
    vertical: 8.0
  );
  static const EdgeInsetsGeometry suffixIconPadding = EdgeInsets.only(
    right: 12.0
  );
  static const EdgeInsetsGeometry contentPadding = EdgeInsetsDirectional.symmetric(
    horizontal: 12.0
  );

  static const BorderRadius borderRadius = BorderRadius.all(Radius.circular(10));

  static const InputBorder border = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(
      width: borderWidth,
      color: AppColor.colorInputBorderCreateMailbox,
    )
  );
  static const InputBorder enableBorder = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(
      width: borderWidth,
      color: AppColor.colorInputBorderCreateMailbox,
    )
  );
  static const InputBorder focusedBorder = OutlineInputBorder(
    borderRadius: borderRadius,
    borderSide: BorderSide(
      width: borderWidth,
      color: AppColor.primaryColor,
    )
  );

  static TextStyle inputtedTextStyle = ThemeUtils.defaultTextStyleInterFont.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: Colors.black,
  );
}