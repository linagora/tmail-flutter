abstract class AiScribeContextMenuAction<T> {
  final T action;

  AiScribeContextMenuAction(this.action);

  String get actionName;

  String? get actionIcon;

  bool get hasSubmenu;

  List<AiScribeContextMenuAction>? get submenuActions;
}
