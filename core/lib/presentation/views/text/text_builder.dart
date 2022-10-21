import 'package:core/presentation/utils/style_utils.dart';
import 'package:flutter/material.dart';

class TextBuilder {
  String? _text;
  TextStyle? _textStyle;
  TextAlign? _textAlign;
  Key? _key;

  TextBuilder key(Key key) {
    _key = key;
    return this;
  }

  TextBuilder text(String text) {
    _text = text;
    return this;
  }

  TextBuilder textStyle(TextStyle textStyle) {
    _textStyle = textStyle;
    return this;
  }

  TextBuilder textAlign(TextAlign textAlign) {
    _textAlign = textAlign;
    return this;
  }

  Text build() {
    return Text(_text ?? '', key: _key ?? const Key('TextBuilder'), style: _textStyle ?? CommonTextStyle.textStyleNormal, textAlign: _textAlign ?? TextAlign.center);
  }
}

class CenterTextBuilder extends TextBuilder {
  @override
  Text build() {
    return Text(_text ?? '', key: _key ?? const Key('TextBuilder'), style: _textStyle, textAlign: TextAlign.center);
  }
}