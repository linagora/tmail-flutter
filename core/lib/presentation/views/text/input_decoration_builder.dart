import 'package:flutter/material.dart';

abstract class InputDecorationBuilder {
  String? prefixText;
  TextStyle? prefixStyle;
  String? labelText;
  TextStyle? labelStyle;
  String? hintText;
  TextStyle? hintStyle;
  EdgeInsetsGeometry? contentPadding;
  OutlineInputBorder? enabledBorder;
  OutlineInputBorder? errorBorder;
  OutlineInputBorder? focusBorder;
  String? errorText;
  TextStyle? errorTextStyle;
  Color? fillColor;

  void setFillColor(Color? newColor) {
    fillColor = newColor;
  }

  void setPrefixText(String? newPrefixText) {
    prefixText = newPrefixText;
  }

  void setPrefixStyle(TextStyle? newPrefixStyle) {
    prefixStyle = newPrefixStyle;
  }

  void setLabelText(String? newLabelText) {
    labelText = newLabelText;
  }

  void setLabelStyle(TextStyle? newLabelStyle) {
    labelStyle = newLabelStyle;
  }

  void setHintText(String? newHintText) {
    hintText = newHintText;
  }

  void setHintStyle(TextStyle? newHintStyle) {
    hintStyle = newHintStyle;
  }

  void setContentPadding(EdgeInsetsGeometry? newContentPadding) {
    contentPadding = newContentPadding;
  }

  void setEnabledBorder(OutlineInputBorder? newEnabledBorder) {
    enabledBorder = newEnabledBorder;
  }

  void setErrorBorder(OutlineInputBorder? newErrorBorder) {
    errorBorder = newErrorBorder;
  }

  void setErrorText(String? newText) {
    errorText = newText;
  }

  void setErrorTextStyle(TextStyle? newStyle) {
    errorTextStyle = newStyle;
  }

  void setFocusBorder(OutlineInputBorder focusBorder) {
    focusBorder = focusBorder;
  }

  InputDecoration build() {
    return InputDecoration(
      prefixText: prefixText,
      labelText: labelText,
      labelStyle: labelStyle,
      hintText: hintText,
      hintStyle: hintStyle,
      contentPadding: contentPadding,
      errorBorder: errorBorder,
      errorText: errorText,
      errorStyle: errorTextStyle,
      enabledBorder: enabledBorder,
      focusedBorder: focusBorder,
    );
  }
}