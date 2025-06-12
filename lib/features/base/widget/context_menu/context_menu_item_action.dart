import 'package:core/presentation/extensions/color_extension.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

typedef OnContextMenuActionClick = void Function(ContextMenuItemAction action);

abstract class ContextMenuItemAction<T> with EquatableMixin {
  final T action;

  ContextMenuItemAction(this.action);

  @override
  List<Object?> get props => [action];

  String get actionIcon;

  Color get actionIconColor => AppColor.gray424244.withOpacity(0.72);

  String get actionName;

  Color get actionNameColor => AppColor.gray424244.withOpacity(0.9);

  void onClick(OnContextMenuActionClick callback) => callback(this);
}
