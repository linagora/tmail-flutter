import 'package:flutter/material.dart';

abstract class InputDecorationBuilder {
  String? prefixText;
  String? labelText;
  TextStyle? labelStyle;
  String? hintText;
  TextStyle? hintStyle;
  EdgeInsets? contentPadding;
  OutlineInputBorder? enabledBorder;

  InputDecorationBuilder setPrefixText(String newPrefixText) {
    prefixText = newPrefixText;
    return this;
  }

  InputDecorationBuilder setLabelText(String newLabelText) {
    labelText = newLabelText;
    return this;
  }

  InputDecorationBuilder setLabelStyle(TextStyle newLabelStyle) {
    labelStyle = newLabelStyle;
    return this;
  }

  InputDecorationBuilder setHintText(String newHintText) {
    hintText = newHintText;
    return this;
  }

  InputDecorationBuilder setHintStyle(TextStyle newHintStyle) {
    hintStyle = newHintStyle;
    return this;
  }

  InputDecorationBuilder setContentPadding(EdgeInsets newContentPadding) {
    contentPadding = newContentPadding;
    return this;
  }

  InputDecorationBuilder setEnabledBorder(OutlineInputBorder newEnabledBorder) {
    enabledBorder = newEnabledBorder;
    return this;
  }

  InputDecoration build() {
    return InputDecoration(
      prefixText: prefixText,
      labelText: labelText,
      labelStyle: labelStyle,
      hintText: hintText,
      hintStyle: hintStyle,
      contentPadding: contentPadding,
      enabledBorder: enabledBorder);
  }
}