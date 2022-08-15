import 'package:flutter/material.dart';

typedef OnCupertinoActionSheetNoIconActionClick<T> = void Function(T data);

abstract class CupertinoActionSheetNoIconBuilder<T> {
  @protected
  final Key? key;
  @protected
  final String actionName;
  @protected
  OnCupertinoActionSheetNoIconActionClick<T>? onCupertinoActionSheetActionClick;

  CupertinoActionSheetNoIconBuilder(
    this.actionName,
    {
      this.key,
    }
  );

  void onActionClick(OnCupertinoActionSheetNoIconActionClick<T> onCupertinoActionSheetActionClick) {
    this.onCupertinoActionSheetActionClick = onCupertinoActionSheetActionClick;
  }

  TextStyle actionTextStyle({TextStyle? textStyle}) {
    return textStyle ?? TextStyle(fontSize: 17, color: Colors.black);
  }

  Widget build();
}