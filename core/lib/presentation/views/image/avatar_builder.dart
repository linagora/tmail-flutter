import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnTapAvatarActionClick = void Function();

class AvatarBuilder {
  Key? _key;
  String? _text;
  double? _size;
  String? _iconStatus;
  Color? _bgColor;
  OnTapAvatarActionClick? _onTapAvatarActionClick;

  AvatarBuilder key(Key key) {
    _key = key;
    return this;
  }

  AvatarBuilder size(double size) {
    _size = size;
    return this;
  }

  AvatarBuilder text(String text) {
    _text = text;
    return this;
  }

  AvatarBuilder iconStatus(String iconStatus) {
    _iconStatus = iconStatus;
    return this;
  }

  AvatarBuilder backgroundColor(Color bgColor) {
    _bgColor = bgColor;
    return this;
  }

  AvatarBuilder addOnTapActionClick(OnTapAvatarActionClick onTapAvatarActionClick) {
    _onTapAvatarActionClick = onTapAvatarActionClick;
    return this;
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
                border: Border.all(color: Colors.white),
                color: _bgColor ?? AppColor.avatarColor),
              child: Text(
                '${_text ?? ''}',
                style: TextStyle(fontSize: 20, color: AppColor.avatarTextColor, fontWeight: FontWeight.w500))),
            if (_iconStatus != null && _iconStatus!.isNotEmpty)
              Align(
                child: SvgPicture.asset(_iconStatus!, width: 12, height: 12, fit: BoxFit.fill),
                alignment: Alignment.bottomRight)
          ],
        )),
    );
  }
}