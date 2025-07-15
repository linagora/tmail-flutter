
import 'package:core/core.dart';
import 'package:flutter/material.dart';

class ContextMenuHeaderBuilder {
  final Key _key;
  String? _label;
  TextStyle? _textStyle;

  ContextMenuHeaderBuilder(this._key);

  void addLabel(String label) {
    _label = label;
  }

  void textStyle(TextStyle textStyle) {
    _textStyle = textStyle;
  }

  ListTile build() {
    return ListTile(
      key: _key,
      title: Transform(
        transform: Matrix4.translationValues(12, 5, 0.0),
        child: Text(
          _label ?? '',
          style: _textStyle ?? ThemeUtils.defaultTextStyleInterFont.copyWith(fontSize: 20.0, color: AppColor.nameUserColor, fontWeight: FontWeight.w500),
        ),
      ));
  }
}