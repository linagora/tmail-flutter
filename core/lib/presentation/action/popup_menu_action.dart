
typedef OnSelectedActionCallback<T> = Function(T action);

class PopupMenuAction<T> {
  final String name;
  final T value;
  final OnSelectedActionCallback<T> onSelected;
  final String? icon;

  PopupMenuAction({
    required this.name,
    required this.value,
    required this.onSelected,
    this.icon,
  });
}