import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/keyboard_shortcuts/widgets/shortcut_row_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/keyboard_shortcuts/keyboard_shortcut.dart';

class ShortcutCategoryList extends StatelessWidget {
  final List<KeyboardShortcut> shortcutsByCategory;

  const ShortcutCategoryList({
    super.key,
    required this.shortcutsByCategory,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 40),
      itemCount: shortcutsByCategory.length,
      itemBuilder: (_, index) {
        final item = shortcutsByCategory[index];
        return ShortcutRow(item: item);
      },
    );
  }
}
