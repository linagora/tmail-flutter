
import 'package:equatable/equatable.dart';

abstract class ContextMenuItemAction<T> with EquatableMixin {
  final T action;
  final ContextMenuItemState state;

  ContextMenuItemAction(this.action, this.state);

  @override
  List<Object?> get props => [action, state];

  bool get isActivated => state == ContextMenuItemState.activated;
}

enum ContextMenuItemState {
  activated,
  deactivated
}