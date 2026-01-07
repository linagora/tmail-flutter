import 'package:core/presentation/extensions/color_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

typedef OnContextMenuActionClick = void Function(ContextMenuItemAction action);

abstract class ContextMenuItemAction<T> with EquatableMixin {
  final T action;
  final String? key;
  final int category;

  ContextMenuItemAction(this.action, {this.key, this.category = -1});

  @override
  List<Object?> get props => [action, key, category];

  String get actionName;

  Color get actionNameColor => AppColor.gray424244.withValues(alpha: 0.9);

  void onClick(OnContextMenuActionClick callback) => callback(this);
}

mixin OptionalIcon {
  String get actionIcon;

  Color get actionIconColor => AppColor.gray424244.withValues(alpha: 0.72);
}

mixin OptionalSelectedIcon<T> {
  String get selectedIcon;

  Color get selectedIconColor => AppColor.primaryMain;

  bool get isArrangeRTL => true;
}

abstract class ContextMenuItemActionRequiredIcon<T>
    extends ContextMenuItemAction<T> with OptionalIcon {
  ContextMenuItemActionRequiredIcon(super.action, {super.key, super.category});
}

abstract class ContextMenuItemActionRequiredSelectedIcon<T>
    extends ContextMenuItemAction<T> with OptionalSelectedIcon<T> {

  final T? selectedAction;

  ContextMenuItemActionRequiredSelectedIcon(
    super.action,
    this.selectedAction, {
    super.key,
    super.category,
  });
}

abstract class ContextMenuItemActionRequiredFull<T>
    extends ContextMenuItemAction<T> with OptionalIcon, OptionalSelectedIcon<T> {
  final T selectedAction;

  ContextMenuItemActionRequiredFull(super.action, this.selectedAction, {super.key, super.category,});
}