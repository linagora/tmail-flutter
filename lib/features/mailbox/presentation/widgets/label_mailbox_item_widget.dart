import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:flutter/material.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/label_mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/empty_mailbox_popup_dialog_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/trailing_mailbox_item_widget.dart';

class LabelMailboxItemWidget extends StatelessWidget {

  final ResponsiveUtils responsiveUtils;
  final MailboxNode mailboxNode;
  final bool showTrailing;
  final bool isItemHovered;
  final bool isSelected;
  final OnClickOpenMenuMailboxNodeAction? onMenuActionClick;
  final OnEmptyMailboxActionCallback? onEmptyMailboxActionCallback;

  const LabelMailboxItemWidget({
    super.key,
    required this.mailboxNode,
    required this.responsiveUtils,
    this.showTrailing = true,
    this.isItemHovered = false,
    this.isSelected = false,
    this.onMenuActionClick,
    this.onEmptyMailboxActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showTrailing)
          Row(
            children: [
              Expanded(
                child: TextOverflowBuilder(
                  mailboxNode.item.getDisplayName(context),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontSize: LabelMailboxItemWidgetStyles.labelFolderTextSize,
                    color: LabelMailboxItemWidgetStyles.labelFolderTextColor,
                    fontWeight: _mailboxNameTextFontWeight
                  ),
                ),
              ),
              if (responsiveUtils.isWebDesktop(context) && mailboxNode.item.allowedHasEmptyAction)
                EmptyMailboxPopupDialogWidget(
                  mailboxNode: mailboxNode,
                  onEmptyMailboxActionCallback: (mailboxNode) => onEmptyMailboxActionCallback?.call(mailboxNode),
                ),
              TrailingMailboxItemWidget(
                mailboxNode: mailboxNode,
                isItemHovered: isItemHovered,
                onMenuActionClick: onMenuActionClick
              )
            ],
          )
        else
          TextOverflowBuilder(
            mailboxNode.item.getDisplayName(context),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: LabelMailboxItemWidgetStyles.labelFolderTextSize,
              color: LabelMailboxItemWidgetStyles.labelFolderTextColor,
              fontWeight: _mailboxNameTextFontWeight
            ),
          ),
        if (mailboxNode.item.isTeamMailboxes)
          TextOverflowBuilder(
            mailboxNode.item.emailTeamMailBoxes,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: LabelMailboxItemWidgetStyles.labelFolderTextSize,
              color: LabelMailboxItemWidgetStyles.teamMailboxEmailTextColor,
              fontWeight: LabelMailboxItemWidgetStyles.labelFolderTextFontWeight
            ),
          )
      ],
    );
  }

  FontWeight get _mailboxNameTextFontWeight {
    if (isSelected || mailboxNode.item.isTeamMailboxes) {
      return LabelMailboxItemWidgetStyles.labelFolderSelectedFontWeight;
    } else {
      return LabelMailboxItemWidgetStyles.labelFolderTextFontWeight;
    }
  }
}