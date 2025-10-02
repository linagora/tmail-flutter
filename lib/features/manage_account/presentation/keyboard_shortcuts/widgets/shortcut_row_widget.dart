import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/extensions/keyboard_shortcut_extension.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/keyboard_shortcuts/widgets/shortcut_key_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/keyboard_shortcuts/keyboard_shortcut.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

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
      child: Wrap(
        spacing: 27,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            item.label,
            style: ThemeUtils.textStyleBodyBody3(
              color: Colors.black,
            ),
          ),
          Text(
            item.context.getDisplayName(AppLocalizations.of(context)),
            style: ThemeUtils.textStyleBodyBody3(
              color: AppColor.gray424244.withValues(alpha: 0.64),
            ),
          ),
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
