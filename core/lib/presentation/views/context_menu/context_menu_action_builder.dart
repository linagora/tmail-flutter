import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnContextMenuActionClick<T> = void Function(T data);

abstract class ContextMenuActionBuilder<T> {
  @protected final Key key;
  @protected final SvgPicture actionIcon;
  @protected final String actionName;
  @protected OnContextMenuActionClick<T>? onContextMenuActionClick;

  ContextMenuActionBuilder(
    this.key,
    this.actionIcon,
    this.actionName);

  void onActionClick(OnContextMenuActionClick<T> onContextMenuActionClick) {
    this.onContextMenuActionClick = onContextMenuActionClick;
  }

  TextStyle actionTextStyle() {
    return ThemeUtils.defaultTextStyleInterFont.copyWith(
      fontSize: 15,
      color: AppColor.nameUserColor);
  }

  Widget build();
}