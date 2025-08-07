import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:flutter/material.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/label_mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_expand_button.dart';

class LabelMailboxVisibilityItemWidget extends StatelessWidget {
  final GlobalKey itemKey;
  final ImagePaths imagePaths;
  final MailboxNode mailboxNode;
  final OnClickExpandMailboxNodeAction onClickExpandMailboxNodeAction;

  const LabelMailboxVisibilityItemWidget({
    super.key,
    required this.itemKey,
    required this.imagePaths,
    required this.mailboxNode,
    required this.onClickExpandMailboxNodeAction,
  });

  @override
  Widget build(BuildContext context) {
    final displayNameWidget = TextOverflowBuilder(
      mailboxNode.item.getDisplayName(context),
      style: _displayNameTextStyle,
    );

    final nameWithExpandIcon = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mailboxNode.hasChildren())
          Flexible(child: displayNameWidget)
        else
          Flexible(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: displayNameWidget,
            ),
          ),
        if (mailboxNode.hasChildren())
          MailboxExpandButton(
            itemKey: itemKey,
            mailboxNode: mailboxNode,
            imagePaths: imagePaths,
            color: mailboxNode.item.isSubscribedMailbox ||
                    mailboxNode.item.isDefault
                ? AppColor.m3SurfaceBackground
                : AppColor.steelGray400,
            onExpandFolderActionClick: onClickExpandMailboxNodeAction,
          ),
      ],
    );

    if (mailboxNode.item.isTeamMailboxes) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          nameWithExpandIcon,
          TextOverflowBuilder(
            mailboxNode.item.emailTeamMailBoxes,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: LabelMailboxItemWidgetStyles.labelFolderTextSize,
                  color: LabelMailboxItemWidgetStyles.teamMailboxEmailTextColor,
                  fontWeight:
                      LabelMailboxItemWidgetStyles.labelFolderTextFontWeight,
                ),
          ),
        ],
      );
    } else {
      return nameWithExpandIcon;
    }
  }

  bool get _isSubscribedMailbox => mailboxNode.item.isSubscribedMailbox;

  TextStyle get _displayNameTextStyle {
    return ThemeUtils.textStyleBodyBody3(
      color: _isSubscribedMailbox || mailboxNode.item.isDefault
          ? Colors.black
          : AppColor.steelGray400,
    );
  }
}
