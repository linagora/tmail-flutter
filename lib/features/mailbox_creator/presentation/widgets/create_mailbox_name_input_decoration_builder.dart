
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class CreateMailboxNameInputDecorationBuilder extends InputDecorationBuilder {

  @override
  InputDecoration build() {
    return InputDecoration(
      enabledBorder: enabledBorder ?? OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1, color: AppColor.colorInputBorderCreateMailbox)),
      focusedBorder: enabledBorder ?? OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1, color: AppColor.colorTextButton)),
      errorBorder: errorBorder ?? OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1, color: AppColor.colorInputBorderErrorVerifyName)),
      prefixText: prefixText,
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: labelStyle ?? TextStyle(color: AppColor.colorNameEmail, fontSize: 16),
      hintText: hintText,
      hintStyle: hintStyle ?? TextStyle(color: AppColor.colorHintInputCreateMailbox, fontSize: 16),
      contentPadding: contentPadding ?? EdgeInsets.all(12),
      errorText: errorText,
      errorStyle: errorTextStyle ?? TextStyle(color: AppColor.colorInputBorderErrorVerifyName, fontSize: 13),
      filled: true,
      fillColor: errorText?.isNotEmpty == true
          ? AppColor.colorInputBackgroundErrorVerifyName
          : AppColor.colorInputBackgroundCreateMailbox);
  }
}