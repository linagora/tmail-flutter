import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:flutter/material.dart';
import 'package:tmail_ui_user/features/base/widget/default_switch_icon_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/model/recipient_forward.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class KeepCopyInInboxWidget extends StatelessWidget {
  final ImagePaths imagePaths;
  final List<RecipientForward> recipientForwards;
  final bool localCopyState;
  final VoidCallback onToggleLocalCopy;

  const KeepCopyInInboxWidget({
    super.key,
    required this.imagePaths,
    required this.recipientForwards,
    required this.localCopyState,
    required this.onToggleLocalCopy,
  });

  @override
  Widget build(BuildContext context) {
    if (recipientForwards.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: InkWell(
              onTap: onToggleLocalCopy,
              child: DefaultSwitchIconWidget(
                imagePaths: imagePaths,
                isEnabled: localCopyState,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context).keepACopyInInbox,
                  style: ThemeUtils.textStyleBodyBody2(color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context).keepACopyInInboxDescription,
                  style: ThemeUtils.textStyleBodyBody2(
                    color: AppColor.gray424244.withValues(alpha: 0.64),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
