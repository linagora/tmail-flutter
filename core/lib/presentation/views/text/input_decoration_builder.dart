import 'package:flutter/material.dart';

abstract class InputDecorationBuilder {
  String? prefixText;
  String? labelText;
  TextStyle? labelStyle;
  String? hintText;
  TextStyle? hintStyle;
  EdgeInsets? contentPadding;
  OutlineInputBorder? enabledBorder;
  OutlineInputBorder? errorBorder;
  String? errorText;
  TextStyle? errorTextStyle;

  void setPrefixText(String newPrefixText) {
    prefixText = newPrefixText;
  }

  void setLabelText(String newLabelText) {
    labelText = newLabelText;
  }

  void setLabelStyle(TextStyle newLabelStyle) {
    labelStyle = newLabelStyle;
  }

  void setHintText(String newHintText) {
    hintText = newHintText;
  }

  void setHintStyle(TextStyle newHintStyle) {
    hintStyle = newHintStyle;
  }

  void setContentPadding(EdgeInsets newContentPadding) {
    contentPadding = newContentPadding;
  }

  void setEnabledBorder(OutlineInputBorder newEnabledBorder) {
    enabledBorder = newEnabledBorder;
  }

  void setErrorBorder(OutlineInputBorder newErrorBorder) {
    errorBorder = newErrorBorder;
  }

  void setErrorText(String? newText) {
    errorText = newText;
  }

  void setErrorTextStyle(TextStyle newStyle) {
    errorTextStyle = newStyle;
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
      enabledBorder: enabledBorder);
  }
}