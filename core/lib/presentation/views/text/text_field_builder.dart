import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

class TextFieldBuilder {
  Key? _key;
  ValueChanged<String>? _onTextChange;
  TextStyle? _textStyle;
  TextInputAction? _textInputAction;
  InputDecoration? _inputDecoration;
  bool? _obscureText;
  int? _maxLines = 1;
  TextEditingController? _textController;
  TextInputType? _keyboardType;

  void key(Key key) {
    _key = key;
  }

  void onChange(ValueChanged<String> onChange) {
    _onTextChange = onChange;
  }

  void textStyle(TextStyle style) {
    _textStyle = style;
  }

  void textInputAction(TextInputAction inputAction) {
    _textInputAction = inputAction;
  }

  void textDecoration(InputDecoration inputDecoration) {
    _inputDecoration = inputDecoration;
  }

  void obscureText(bool obscureText) {
    _obscureText = obscureText;
  }

  void setText(String value) {
    _textController = TextEditingController.fromValue(TextEditingValue(text: value));
  }

  void addController(TextEditingController textEditingController) {
    _textController = textEditingController;
  }

  void maxLines(int? value) {
    _maxLines = value;
  }

  void keyboardType(TextInputType? value) {
    _keyboardType = value;
  }

  TextField build() {
    return TextField(
      key: _key ?? Key('TextFieldBuilder'),
      onChanged: _onTextChange,
      cursorColor: AppColor.primaryColor,
      controller: _textController,
      autocorrect: false,
      textInputAction: _textInputAction,
      decoration: _inputDecoration,
      maxLines: _maxLines,
      keyboardAppearance: Brightness.light,
      style: _textStyle ?? TextStyle(color: AppColor.textFieldTextColor),
      obscureText: _obscureText ?? false,
      keyboardType: _keyboardType,
    );
  }
}