
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnPressActionClick = void Function();

class ButtonBuilder {
  OnPressActionClick? _onPressActionClick;

  String? _icon;
  String? _text;
  double? _size;
  EdgeInsets? _paddingIcon;
  bool? _isVertical;
  Key? _key;
  Color? _iconColor;
  TextStyle? _textStyle;

  void key(Key key) {
    _key = key;
  }

  void size(double size) {
    _size = size;
  }

  void iconColor(Color color) {
    _iconColor = color;
  }

  void textStyle(TextStyle style) {
    _textStyle = style;
  }

  void paddingIcon(EdgeInsets paddingIcon) {
    _paddingIcon = paddingIcon;
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
    padding: _paddingIcon ?? EdgeInsets.all(10),
    child: SvgPicture.asset(_icon ?? '', width: _size ?? 24, height: _size ?? 24, fit: BoxFit.fill, color: _iconColor));

  Widget _buildText() {
    return Text(
      '${_text ?? ''}',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _textStyle ?? TextStyle(fontSize: 12, color: AppColor.textButtonColor, fontWeight: FontWeight.w500),
    );
  }
}