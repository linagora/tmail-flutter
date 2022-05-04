
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
      labelStyle: labelStyle ?? const TextStyle(color: AppColor.textFieldLabelColor, fontSize: 16),
      hintText: hintText,
      hintStyle: hintStyle ?? const TextStyle(color: AppColor.textFieldHintColor, fontSize: 16),
      contentPadding: contentPadding ?? const EdgeInsets.only(left: 25, top: 15, bottom: 15, right: 25),
      filled: true,
      fillColor: AppColor.textFieldBorderColor);
  }
}