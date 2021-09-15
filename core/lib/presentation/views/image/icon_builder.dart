import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnPressIconActionClick = void Function();

class IconBuilder {
  Key? _key;
  double? _size;
  String? _icon;
  OnPressIconActionClick? _onPressIconActionClick;

  IconBuilder(this._icon);

  void key(Key key) {
    _key = key;
  }

  void size(double size) {
    _size = size;
  }

  void addOnTapActionClick(OnPressIconActionClick onPressIconActionClick) {
    _onPressIconActionClick = onPressIconActionClick;
  }

  Widget build() {
    return Container(
      key: _key,
      width: _size ?? 40,
      height: _size ?? 40,
      alignment: Alignment.center,
      padding: EdgeInsets.all(3),
      child: IconButton(
        padding: EdgeInsets.zero,
        iconSize: _size ?? 40,
        icon: SvgPicture.asset(_icon!, width: _size ?? 40, height: _size ?? 40, fit: BoxFit.fill),
        onPressed: () => {
          if (_onPressIconActionClick != null) {
            _onPressIconActionClick!()
          }
        })
    );
  }
}