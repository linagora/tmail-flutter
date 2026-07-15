import 'package:equatable/equatable.dart';

enum ShortcutCategory {
  navigationAndClosing,
  readingAndReplying,
  messageManagementAndSelection,
}

class KeyboardShortcut with EquatableMixin {
  final String label;
  final ShortcutCategory category;
  final List<String> keys;

  const KeyboardShortcut({
    required this.label,
    required this.category,
    required this.keys,
  });

  @override
  List<Object?> get props => [
    label,
    category,
    keys,
  ];
}
