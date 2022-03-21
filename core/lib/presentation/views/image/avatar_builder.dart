import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

typedef OnTapAvatarActionClick = void Function();

class AvatarBuilder {
  Key? _key;
  String? _text;
  double? _size;
  Color? _bgColor;
  Color? _textColor;
  OnTapAvatarActionClick? _onTapAvatarActionClick;
  List<Color>? _avatarColors;
  List<BoxShadow>? _boxShadows;
  TextStyle? _textStyle;

  void key(Key key) {
    _key = key;
  }

  void size(double size) {
    _size = size;
  }

  void text(String text) {
    _text = text;
  }

  void backgroundColor(Color bgColor) {
    _bgColor = bgColor;
  }

  void textColor(Color textColor) {
    _textColor = textColor;
  }

  void avatarColor(List<Color>? avatarColors) {
    _avatarColors = avatarColors;
  }

  void addBoxShadows(List<BoxShadow>? boxShadows) {
    _boxShadows = boxShadows;
  }

  void addTextStyle(TextStyle? textStyle) {
    _textStyle = textStyle;
  }

  void addOnTapActionClick(OnTapAvatarActionClick onTapAvatarActionClick) {
    _onTapAvatarActionClick = onTapAvatarActionClick;
  }

  Widget build() {
    return GestureDetector(
      onTap: () {
        if (_onTapAvatarActionClick != null) {
          _onTapAvatarActionClick!();
        }},
      child: Container(
          key: _key,
          width: _size ?? 40,
          height: _size ?? 40,
          padding: EdgeInsets.zero,
          margin: EdgeInsets.zero,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular((_size ?? 40) * 0.5),
              border: Border.all(color: Colors.transparent),
              boxShadow: _boxShadows ?? [],
              gradient: _avatarColors?.isNotEmpty == true
                  ? LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, tileMode: TileMode.decal, colors: _avatarColors ?? [])
                  : null,
              color: _bgColor ?? AppColor.avatarColor
          ),
          child: Text(
              '${_text ?? ''}',
              style: _textStyle ?? TextStyle(fontSize: 20, color: _textColor ?? AppColor.avatarTextColor, fontWeight: FontWeight.w500)
          )
      ),
    );
  }
}