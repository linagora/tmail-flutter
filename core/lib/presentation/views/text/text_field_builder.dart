import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class TextFieldBuilder {
  Key? _key;
  ValueChanged<String>? _onTextChange;
  TextStyle? _textStyle;
  TextInputAction? _textInputAction;
  InputDecoration? _inputDecoration;
  bool? _obscureText;

  TextFieldBuilder key(Key key) {
    _key = key;
    return this;
  }

  TextFieldBuilder onChange(ValueChanged<String> onChange) {
    _onTextChange = onChange;
    return this;
  }

  TextFieldBuilder textStyle(TextStyle style) {
    _textStyle = style;
    return this;
  }

  TextFieldBuilder textInputAction(TextInputAction inputAction) {
    _textInputAction = inputAction;
    return this;
  }

  TextFieldBuilder textDecoration(InputDecoration inputDecoration) {
    _inputDecoration = inputDecoration;
    return this;
  }

  TextFieldBuilder obscureText(bool obscureText) {
    _obscureText = obscureText;
    return this;
  }

  TextField build() {
    return TextField(
      key: _key ?? Key('TextFieldBuilder'),
      onChanged: _onTextChange,
      cursorColor: AppColor.primaryColor,
      textInputAction: _textInputAction,
      decoration: _inputDecoration,
      style: _textStyle ?? TextStyle(color: AppColor.textFieldTextColor),
      obscureText: _obscureText ?? false,
    );
  }
}