import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

typedef OnOpenSearchMailActionClick = void Function();

class TextFieldBuilder {
  Key? _key;
  VoidCallback? _onTapInput;
  ValueChanged<String>? _onTextChange;
  ValueChanged<String>? _onTextSubmitted;
  TextStyle? _textStyle;
  TextInputAction? _textInputAction;
  InputDecoration? _inputDecoration;
  bool? _obscureText;
  int? _maxLines = 1;
  TextEditingController? _textController;
  TextInputType? _keyboardType;
  Color? _cursorColor;
  bool? _autoFocus;
  FocusNode? _focusNode;

  void key(Key key) {
    _key = key;
  }

  void onTapInput(VoidCallback onTap) {
    _onTapInput = onTap;
  }

  void onChange(ValueChanged<String> onChange) {
    _onTextChange = onChange;
  }

  void onSubmitted(ValueChanged<String> onSubmitted) {
    _onTextSubmitted = onSubmitted;
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

  void addController(TextEditingController? textEditingController) {
    _textController = textEditingController;
  }

  void maxLines(int? value) {
    _maxLines = value;
  }

  void keyboardType(TextInputType? value) {
    _keyboardType = value;
  }

  void cursorColor(Color? color) {
    _cursorColor = color;
  }

  void autoFocus(bool autoFocus) {
    _autoFocus = autoFocus;
  }

  void addFocusNode(FocusNode? focusNode) {
    _focusNode = focusNode;
  }

  TextField build() {
    return TextField(
      key: _key ?? Key('TextFieldBuilder'),
      onChanged: _onTextChange,
      onTap: _onTapInput,
      cursorColor: _cursorColor ?? AppColor.primaryColor,
      controller: _textController,
      autocorrect: false,
      textInputAction: _textInputAction,
      decoration: _inputDecoration,
      maxLines: _maxLines,
      keyboardAppearance: Brightness.light,
      style: _textStyle ?? TextStyle(color: AppColor.textFieldTextColor),
      obscureText: _obscureText ?? false,
      keyboardType: _keyboardType,
      onSubmitted: _onTextSubmitted,
      autofocus: _autoFocus ?? false,
      focusNode: _focusNode,
    );
  }
}