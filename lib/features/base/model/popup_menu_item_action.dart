import 'package:core/presentation/extensions/color_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

typedef OnPopupMenuActionClick = void Function(PopupMenuItemAction action);
typedef OnHoverShowSubmenu = void Function(GlobalKey key);

abstract class PopupMenuItemAction<T> with EquatableMixin {
  final T action;
  final String? key;
  final int category;
  final Widget? submenu;

  PopupMenuItemAction(
    this.action, {
    this.key,
    this.category = -1,
    this.submenu,
  });

  @override
  List<Object?> get props => [action, key, category, submenu];

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

  bool get isArrangeRTL => true;
}

mixin OptionalPopupHoverIcon {
  String get hoverIcon;

  Color get hoverIconColor => AppColor.steelGrayA540;

  double get hoverIconSize => 16.0;
}

abstract class PopupMenuItemActionRequiredIcon<T> extends PopupMenuItemAction<T>
    with OptionalPopupIcon, OptionalPopupHoverIcon {
  PopupMenuItemActionRequiredIcon(
    super.action, {
    super.key,
    super.category,
    super.submenu,
  });
}

abstract class PopupMenuItemActionRequiredSelectedIcon<T>
    extends PopupMenuItemAction<T> with OptionalPopupSelectedIcon<T> {
  final T? selectedAction;

  PopupMenuItemActionRequiredSelectedIcon(
    super.action,
    this.selectedAction, {
    super.key,
    super.category,
    super.submenu,
  });
}

abstract class PopupMenuItemActionRequiredFull<T> extends PopupMenuItemAction<T>
    with OptionalPopupIcon, OptionalPopupSelectedIcon<T> {
  final T selectedAction;

  PopupMenuItemActionRequiredFull(
    super.action,
    this.selectedAction, {
    super.key,
    super.category,
    super.submenu,
  });
}

abstract class PopupMenuItemActionRequiredIconWithMultipleSelected<T>
    extends PopupMenuItemAction<T>
    with OptionalPopupIcon, OptionalPopupSelectedIcon<T> {
  final List<T> selectedActions;

  PopupMenuItemActionRequiredIconWithMultipleSelected(
    super.action,
    this.selectedActions, {
    super.key,
    super.category,
    super.submenu,
  });
}
