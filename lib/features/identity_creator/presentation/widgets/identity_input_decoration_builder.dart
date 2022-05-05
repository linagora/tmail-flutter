
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class IdentityInputDecorationBuilder extends InputDecorationBuilder {

  @override
  InputDecoration build() {
    return InputDecoration(
      enabledBorder: enabledBorder ?? const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1, color: AppColor.colorInputBorderCreateMailbox)),
      focusedBorder: enabledBorder ?? const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1, color: AppColor.colorTextButton)),
      errorBorder: errorBorder ?? const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(width: 1, color: AppColor.colorInputBorderErrorVerifyName)),
      focusedErrorBorder: errorBorder ?? const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
          borderSide: BorderSide(width: 1, color: AppColor.colorInputBorderErrorVerifyName)),
      prefixText: prefixText,
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: labelStyle ?? const TextStyle(color: Colors.black, fontSize: 16),
      hintText: hintText,
      isDense: true,
      hintStyle: hintStyle ?? const TextStyle(color: AppColor.colorHintInputCreateMailbox, fontSize: 16),
      contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      errorText: errorText,
      errorStyle: errorTextStyle ?? const TextStyle(color: AppColor.colorInputBorderErrorVerifyName, fontSize: 13),
      filled: true,
      fillColor: errorText?.isNotEmpty == true
          ? AppColor.colorInputBackgroundErrorVerifyName
          : AppColor.colorInputBackgroundCreateMailbox);
  }
}