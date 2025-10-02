import 'package:equatable/equatable.dart';

enum ShortcutCategory {
  navigationAndClosing,
  readingAndReplying,
  messageManagementAndSelection,
}

enum ShortcutContext {
  mailComposer,
  focusOnSearch,
  openedModal,
  mailboxList,
  mailboxListWithSelectedEmail,
  openedMailView,
}

class KeyboardShortcut with EquatableMixin {
  final String label;
  final ShortcutCategory category;
  final ShortcutContext context;
  final List<String> keys;

  const KeyboardShortcut({
    required this.label,
    required this.category,
    required this.context,
    required this.keys,
  });

  @override
  List<Object?> get props => [
    label,
    category,
    context,
    keys,
  ];
}
