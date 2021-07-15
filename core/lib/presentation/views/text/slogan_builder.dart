import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A builder which builds a reusable slogan widget.
/// This contains the logo and the slogan text.
/// The elements are arranged in a column.
class SloganBuilder {
  Key? _key;
  String? _text;
  TextStyle? _textStyle;
  TextAlign? _textAlign;
  String? _logo;

  SloganBuilder key(Key key) {
    _key = key;
    return this;
  }

  SloganBuilder setSloganText(String text) {
    _text = text;
    return this;
  }

  SloganBuilder setSloganTextStyle(TextStyle textStyle) {
    _textStyle = textStyle;
    return this;
  }

  SloganBuilder setSloganTextAlign(TextAlign textAlign) {
    _textAlign = textAlign;
    return this;
  }

  SloganBuilder setLogo(String logo) {
    _logo = logo;
    return this;
  }

  Widget build() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _logo != null ? SvgPicture.asset(_logo!, width: 150, height: 150) : SizedBox.shrink(),
        Padding(
          padding: EdgeInsets.only(top: 16, left: 16, right: 16),
          child: Text(_text ?? '', key: _key, style: _textStyle, textAlign: _textAlign),
        ),
      ],
    );
  }
}
