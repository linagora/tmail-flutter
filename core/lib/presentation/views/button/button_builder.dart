import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnPressActionClick = void Function();

class ButtonBuilder {
  OnPressActionClick? _onPressActionClick;

  String? _icon;
  String? _text;
  double? _size;
  double? _padding;
  bool? _isVertical;
  Key? _key;
  Color? _color;

  void key(Key key) {
    _key = key;
  }

  void size(double size) {
    _size = size;
  }

  void color(Color color) {
    _color = color;
  }

  void padding(double padding) {
    _padding = padding;
  }

  void text(String text, {required bool isVertical}) {
    _text = text;
    _isVertical = isVertical;
  }

  ButtonBuilder(this._icon);

  void onPressActionClick(OnPressActionClick onPressActionClick) {
    _onPressActionClick = onPressActionClick;
  }

  Widget build() {
    return GestureDetector(
      onTap: () {
        if (_onPressActionClick != null) {
          _onPressActionClick!();
        }
      },
      child: Container(
        key: _key,
        alignment: Alignment.center,
        color: Colors.transparent,
        child: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.zero),
          child: _buildBody()
        )
      )
    );
  }

  Widget _buildBody() {
    if (_text != null) {
      return _isVertical!
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              _buildText(),
            ])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              _buildText(),
            ]);
    } else {
      return _buildIcon();
    }
  }

  Widget _buildIcon() => Padding(
    padding: EdgeInsets.all(_padding ?? 10),
    child: SvgPicture.asset(_icon ?? '', width: _size ?? 24, height: _size ?? 24, fit: BoxFit.fill, color: _color));

  Widget _buildText() {
    return Text(
      '${_text ?? ''}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12, color: AppColor.textButtonColor, fontWeight: FontWeight.w500),
    );
  }
}