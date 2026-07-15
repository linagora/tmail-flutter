import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/keyboard_shortcuts/widgets/shortcut_key_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/keyboard_shortcuts/keyboard_shortcut.dart';

class ShortcutRow extends StatelessWidget {
  final KeyboardShortcut item;

  const ShortcutRow({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(
        top: 5,
        bottom: 21,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              item.label,
              style: ThemeUtils.textStyleBodyBody3(
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Row(
            mainAxisSize: MainAxisSize.min,
            children:
                item.keys.map((key) => ShortcutKeyWidget(label: key)).toList(),
          ),
        ],
      ),
    );
  }
}
