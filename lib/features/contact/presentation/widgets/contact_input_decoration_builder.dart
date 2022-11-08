
import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/views/text/input_decoration_builder.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';

class ContactInputDecorationBuilder extends InputDecorationBuilder {

  @override
  InputDecoration build() {
    return InputDecoration(
      enabledBorder: enabledBorder ?? const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          width: 0.5,
          color: AppColor.colorInputBorderCreateMailbox)),
      focusedBorder: enabledBorder ?? const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          width: 1,
          color: AppColor.colorTextButton)),
      errorBorder: errorBorder ?? const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          width: 1,
          color: AppColor.colorInputBorderErrorVerifyName)),
      focusedErrorBorder: errorBorder ?? const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(
          width: 0.5,
          color: AppColor.colorInputBorderErrorVerifyName)),
      prefixText: prefixText,
      labelText: labelText,
      floatingLabelBehavior: FloatingLabelBehavior.never,
      labelStyle: labelStyle ?? const TextStyle(
          color: Colors.black,
          fontSize: 16,
          fontWeight: FontWeight.w500),
      hintText: hintText,
      isDense: true,
      hintStyle: hintStyle ?? const TextStyle(
        color: AppColor.colorEmailAddressFull,
        fontWeight: FontWeight.w500,
        fontSize: 16),
      contentPadding: const EdgeInsets.symmetric(
        vertical: BuildUtils.isWeb ? 16 : 12,
        horizontal: 12),
      errorText: errorText,
      errorStyle: errorTextStyle ?? const TextStyle(
        color: AppColor.colorInputBorderErrorVerifyName,
        fontSize: 13),
      filled: true,
      fillColor: errorText?.isNotEmpty == true
        ? AppColor.colorInputBackgroundErrorVerifyName
        : AppColor.colorInputBackgroundCreateMailbox);
  }
}