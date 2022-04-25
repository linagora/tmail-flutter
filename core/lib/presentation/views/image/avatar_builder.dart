import 'package:core/presentation/extensions/color_extension.dart';
import 'package:flutter/material.dart';

typedef OnTapAvatarActionClick = void Function();
typedef OnTapAvatarActionWithPositionClick = void Function(RelativeRect? position);

class AvatarBuilder {

  BuildContext? _context;
  Key? _key;
  String? _text;
  double? _size;
  Color? _bgColor;
  Color? _textColor;
  OnTapAvatarActionClick? _onTapAvatarActionClick;
  OnTapAvatarActionWithPositionClick? _onTapAvatarActionWithPositionClick;
  List<Color>? _avatarColors;
  List<BoxShadow>? _boxShadows;
  TextStyle? _textStyle;

  void key(Key key) {
    _key = key;
  }

  void context(BuildContext context) {
    _context = context;
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

  void addOnTapAvatarActionWithPositionClick(OnTapAvatarActionWithPositionClick onTapAvatarActionWithPositionClick) {
    _onTapAvatarActionWithPositionClick = onTapAvatarActionWithPositionClick;
  }

  Widget build() {
    return InkWell(
      onTap: () => _onTapAvatarActionClick != null ? _onTapAvatarActionClick?.call() : null,
      onTapDown: (detail) {
        if (_onTapAvatarActionWithPositionClick != null && _context != null) {
          final screenSize = MediaQuery.of(_context!).size;
          final offset = detail.globalPosition;
          final position = RelativeRect.fromLTRB(
            offset.dx,
            offset.dy,
            screenSize.width - offset.dx,
            screenSize.height - offset.dy,
          );
          _onTapAvatarActionWithPositionClick?.call(position);
        }
      },
      borderRadius: BorderRadius.circular((_size ?? 40) / 2),
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