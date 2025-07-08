import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnCupertinoActionSheetActionClick<T> = void Function(T data);

abstract class CupertinoActionSheetActionBuilder<T> {
  @protected
  final Key key;
  @protected
  final SvgPicture actionIcon;
  @protected
  final String actionName;
  @protected
  OnCupertinoActionSheetActionClick<T>? onCupertinoActionSheetActionClick;

  CupertinoActionSheetActionBuilder(
    this.key,
    this.actionIcon,
    this.actionName,
  );

  void onActionClick(OnCupertinoActionSheetActionClick<T> onCupertinoActionSheetActionClick) {
    this.onCupertinoActionSheetActionClick = onCupertinoActionSheetActionClick;
  }

  TextStyle actionTextStyle({TextStyle? textStyle}) {
    return textStyle ??
        ThemeUtils.defaultTextStyleInterFont.copyWith(
          fontSize: 17,
          color: AppColor.colorNameEmail,
        );
  }

  Widget build();
}
