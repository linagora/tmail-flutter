
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class LoginInputDecorationBuilder extends InputDecorationBuilder {

  @override
  InputDecoration build() {
    return InputDecoration(
      enabledBorder: enabledBorder ?? OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(29)),
        borderSide: BorderSide(width: 1, color: AppColor.textFieldBorderColor)),
      focusedBorder: enabledBorder ?? OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(29)),
        borderSide: BorderSide(width: 2, color: AppColor.textFieldFocusedBorderColor)),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(29)),
        borderSide: BorderSide(width: 1, color: AppColor.textFieldErrorBorderColor)),
      prefixText: prefixText,
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: labelStyle ?? TextStyle(color: AppColor.textFieldLabelColor, fontSize: 16),
      hintText: hintText,
      hintStyle: hintStyle ?? TextStyle(color: AppColor.textFieldHintColor, fontSize: 16),
      contentPadding: contentPadding ?? EdgeInsets.only(left: 25, top: 15, bottom: 15, right: 25),
      filled: true,
      fillColor: AppColor.textFieldBorderColor);
  }
}