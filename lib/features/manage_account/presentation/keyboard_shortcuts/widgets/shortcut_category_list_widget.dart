import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/keyboard_shortcuts/widgets/shortcut_row_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/keyboard_shortcuts/keyboard_shortcut.dart';

class ShortcutCategoryList extends StatelessWidget {
  final List<KeyboardShortcut> shortcutsByCategory;

  /// Constrains each row width so the key chips align in a fixed column.
  /// When null, rows span the full available width (mobile).
  final double? rowMaxWidth;

  const ShortcutCategoryList({
    super.key,
    required this.shortcutsByCategory,
    this.rowMaxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 40),
      itemCount: shortcutsByCategory.length,
      itemBuilder: (_, index) {
        final row = ShortcutRow(item: shortcutsByCategory[index]);
        if (rowMaxWidth == null) return row;

        return Align(
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: rowMaxWidth!),
            child: row,
          ),
        );
      },
    );
  }
}
