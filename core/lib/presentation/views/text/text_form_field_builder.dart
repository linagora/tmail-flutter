import 'package:flutter/material.dart';

typedef OnTapActionClick = void Function();

class TextFormFieldBuilder {
  Key? _key;
  ValueChanged<String>? _onTextChange;
  InputDecoration? _inputDecoration;
  TextInputAction? _textInputAction;
  TextStyle? _textStyle;
  OnTapActionClick? _onTapActionClick;

  void key(Key key) {
    _key = key;
  }

  void onChange(ValueChanged<String> onChange) {
    _onTextChange = onChange;
  }

  void textStyle(TextStyle style) {
    _textStyle = style;
  }

  void textDecoration(InputDecoration inputDecoration) {
    _inputDecoration = inputDecoration;
  }

  void textInputAction(TextInputAction inputAction) {
    _textInputAction = inputAction;
  }

  void addOnTapActionClick(OnTapActionClick onTapActionClick) {
    _onTapActionClick = onTapActionClick;
  }

  TextFormField build() {
    return TextFormField(
      key: _key ?? Key('text_form_field_builder'),
      keyboardType: TextInputType.multiline,
      maxLines: null,
      onChanged: _onTextChange,
      style: _textStyle,
      decoration: _inputDecoration,
      textInputAction: _textInputAction,
      onTap: () {
        if (_onTapActionClick != null) {
          _onTapActionClick!();
        }
      },
    );
  }
}