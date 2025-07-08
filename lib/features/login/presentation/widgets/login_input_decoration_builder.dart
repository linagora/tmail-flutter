
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class LoginInputDecorationBuilder extends InputDecorationBuilder {

  @override
  InputDecoration build() {
    return InputDecoration(
      enabledBorder: enabledBorder ?? const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1, color: AppColor.textFieldBorderColor)),
      focusedBorder:  focusBorder ?? const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 2, color: AppColor.textFieldFocusedBorderColor)),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1, color: AppColor.textFieldErrorBorderColor)),
      prefixText: prefixText,
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: labelStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(color: AppColor.textFieldLabelColor, fontSize: 16),
      hintText: hintText,
      hintStyle: hintStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(color: AppColor.textFieldHintColor, fontSize: 16),
      contentPadding: contentPadding ?? const EdgeInsetsDirectional.only(start: 25, top: 15, bottom: 15, end: 25),
      filled: true,
      fillColor: AppColor.textFieldBorderColor);
  }
}