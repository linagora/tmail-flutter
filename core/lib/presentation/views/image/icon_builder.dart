import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnPressIconActionClick = void Function();

class IconBuilder {
  Key? _key;
  double? _size;
  final String? _icon;
  EdgeInsets? _padding;
  OnPressIconActionClick? _onPressIconActionClick;

  IconBuilder(this._icon);

  void key(Key key) {
    _key = key;
  }

  void size(double size) {
    _size = size;
  }

  void padding(EdgeInsets padding) {
    _padding = padding;
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
      padding: _padding ?? const EdgeInsets.all(3),
      child: Material(
          borderRadius: BorderRadius.circular((_size ?? 40) / 2),
          color: Colors.transparent,
          child: IconButton(
              padding: EdgeInsets.zero,
              iconSize: _size ?? 40,
              splashRadius: 20,
              icon: SvgPicture.asset(_icon!, width: _size ?? 40, height: _size ?? 40, fit: BoxFit.fill),
              onPressed: () => {
                if (_onPressIconActionClick != null) {
                  _onPressIconActionClick!()
                }
              }
          )
      )
    );
  }
}