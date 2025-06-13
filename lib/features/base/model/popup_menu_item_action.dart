import 'package:core/presentation/extensions/color_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

typedef OnPopupMenuActionClick = void Function(PopupMenuItemAction action);

abstract class PopupMenuItemAction<T> with EquatableMixin {
  final T action;

  PopupMenuItemAction(this.action);

  @override
  List<Object?> get props => [action];

  String get actionName;

  Color get actionNameColor => Colors.black;

  EdgeInsetsGeometry get itemPadding =>
      const EdgeInsets.symmetric(horizontal: 12);

  void onClick(OnPopupMenuActionClick callback) => callback(this);
}

mixin OptionalPopupIcon {
  String get actionIcon;

  Color get actionIconColor => AppColor.steelGrayA540;

  double get actionIconSize => 20.0;
}

mixin OptionalPopupSelectedIcon<T> {
  String get selectedIcon;

  Color get selectedIconColor => AppColor.primaryMain;

  double get selectedIconSize => 16.0;
}

abstract class PopupMenuItemActionRequiredIcon<T> extends PopupMenuItemAction<T>
    with OptionalPopupIcon {
  PopupMenuItemActionRequiredIcon(super.action);
}

abstract class PopupMenuItemActionRequiredSelectedIcon<T>
    extends PopupMenuItemAction<T> with OptionalPopupSelectedIcon<T> {
  final T? selectedAction;

  PopupMenuItemActionRequiredSelectedIcon(super.action, this.selectedAction);
}

abstract class PopupMenuItemActionRequiredFull<T> extends PopupMenuItemAction<T>
    with OptionalPopupIcon, OptionalPopupSelectedIcon<T> {
  final T selectedAction;

  PopupMenuItemActionRequiredFull(super.action, this.selectedAction);
}
