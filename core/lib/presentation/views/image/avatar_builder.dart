import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';

typedef OnTapAvatarActionClick = void Function();

class AvatarBuilder {
  Key? _key;
  String? _text;
  double? _size;
  // String? _iconStatus;
  Color? _bgColor;
  Color? _textColor;
  OnTapAvatarActionClick? _onTapAvatarActionClick;
  List<Color>? _avatarColors;
  List<BoxShadow>? _boxShadows;

  void key(Key key) {
    _key = key;
  }

  void size(double size) {
    _size = size;
  }

  void text(String text) {
    _text = text;
  }

  // AvatarBuilder iconStatus(String iconStatus) {
  //   _iconStatus = iconStatus;
  //   return this;
  // }

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
        alignment: Alignment.center,
        child: Stack(
          children: [
            Container(
              width: _size ?? 40,
              height: _size ?? 40,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular((_size ?? 40) / 2),
                border: Border.all(color: Colors.transparent),
                boxShadow: _boxShadows ?? [],
                gradient: _avatarColors?.isNotEmpty == true
                  ? LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      tileMode: TileMode.decal,
                      colors: _avatarColors ?? [])
                  : null,
                color: _bgColor ?? AppColor.avatarColor),
              child: Text(
                '${_text ?? ''}',
                style: TextStyle(fontSize: 20, color: _textColor ?? AppColor.avatarTextColor, fontWeight: FontWeight.w500))),
            // if (_iconStatus != null && _iconStatus!.isNotEmpty)
            //   Align(
            //     child: SvgPicture.asset(_iconStatus!, width: 12, height: 12, fit: BoxFit.fill),
            //     alignment: Alignment.bottomRight)
          ],
        )),
    );
  }
}