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
  bool? _isVertical;
  Key? _key;

  ButtonBuilder key(Key key) {
    _key = key;
    return this;
  }

  ButtonBuilder size(double size) {
    _size = size;
    return this;
  }

  ButtonBuilder text(String text, {required bool isVertical}) {
    _text = text;
    _isVertical = isVertical;
    return this;
  }

  ButtonBuilder(this._icon);

  ButtonBuilder onBackActionClick(OnPressActionClick onPressActionClick) {
    _onPressActionClick = onPressActionClick;
    return this;
  }

  Widget build() {
    return Container(
      alignment: Alignment.center,
      color: Colors.transparent,
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: GestureDetector(
          child: _buildBody(),
          onTap: () {
            if (_onPressActionClick != null) {
              _onPressActionClick!();
            }
          },
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
              SizedBox(height: 8),
              _buildText(),
            ])
        : Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIcon(),
              SizedBox(width: 8),
              _buildText(),
            ]);
    } else {
      return _buildIcon();
    }
  }

  Widget _buildIcon() => SvgPicture.asset(_icon ?? '', width: _size ?? 24, height: _size ?? 24, fit: BoxFit.fill);

  Widget _buildText() {
    return Text(
      '${_text ?? ''}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(fontSize: 12, color: AppColor.textButtonColor, fontWeight: FontWeight.w500),
    );
  }
}