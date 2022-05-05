import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A builder which builds a reusable slogan widget.
/// This contains the logo and the slogan text.
/// The elements are arranged in a column or row.

typedef OnTapCallback = void Function();

class SloganBuilder {

  final bool arrangedByHorizontal;

  Key? _key;
  String? _text;
  TextStyle? _textStyle;
  TextAlign? _textAlign;
  String? _logoSVG;
  String? _logo;
  double? _sizeLogo;
  OnTapCallback? _onTapCallback;
  EdgeInsetsGeometry? _padding;

  SloganBuilder({this.arrangedByHorizontal = false});

  void key(Key key) {
    _key = key;
  }

  void setSloganText(String text) {
    _text = text;
  }

  void setSloganTextStyle(TextStyle textStyle) {
    _textStyle = textStyle;
  }

  void setSloganTextAlign(TextAlign textAlign) {
    _textAlign = textAlign;
  }

  void setLogo(String logo) {
    _logo = logo;
  }

  void setLogoSVG(String logoSVG) {
    _logoSVG = logoSVG;
  }

  void setSizeLogo(double? size) {
    _sizeLogo = size;
  }

  void addOnTapCallback(OnTapCallback? onTapCallback) {
    _onTapCallback = onTapCallback;
  }

  void setPadding(EdgeInsetsGeometry? padding) {
    _padding = padding;
  }

  Widget build() {
    if (!arrangedByHorizontal) {
      return InkWell(
        onTap: () => _onTapCallback?.call(),
        child: Column(children: [
          _logoApp(),
          Padding(
            padding: _padding ?? EdgeInsets.only(top: 16, left: 16, right: 16),
            child: Text(_text ?? '', key: _key, style: _textStyle, textAlign: _textAlign),
          ),
        ]),
      );
    } else {
      return InkWell(
        onTap: () => _onTapCallback?.call(),
        child: Row(children: [
          _logoApp(),
          Padding(
            padding: _padding ?? EdgeInsets.symmetric(horizontal: 10),
            child: Text(_text ?? '', key: _key, style: _textStyle, textAlign: _textAlign),
          ),
        ]),
      );
    }
  }

  Widget _logoApp() {
    if (_logoSVG != null) {
      return SvgPicture.asset(_logoSVG!, width: _sizeLogo ?? 150, height: _sizeLogo ?? 150);
    } else if (_logo != null) {
      return Image(
          image: AssetImage(_logo!),
          fit: BoxFit.fill,
          width: _sizeLogo ?? 150,
          height: _sizeLogo ?? 150,
          alignment: Alignment.center);
    }
    return SizedBox.shrink();
  }
}
