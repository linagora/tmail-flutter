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
      children: [
        if (showTrailing)
          Row(
            children: [
              Expanded(
                child: TextOverflowBuilder(
                  mailboxNode.item.getDisplayName(context),
                  style: TextStyle(
                    fontSize: _mailboxNameTextSize,
                    color: _mailboxNameTextColor,
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
            style: TextStyle(
              fontSize: _mailboxNameTextSize,
              color: _mailboxNameTextColor,
              fontWeight: _mailboxNameTextFontWeight
            ),
          ),
        if (mailboxNode.item.isTeamMailboxes)
          TextOverflowBuilder(
            mailboxNode.item.emailTeamMailBoxes,
            style: const TextStyle(
              fontSize: LabelMailboxItemWidgetStyles.teamMailboxTextSize,
              color: LabelMailboxItemWidgetStyles.teamMailboxTextColor,
              fontWeight: LabelMailboxItemWidgetStyles.teamMailboxTextFontWeight
            ),
          )
      ],
    );
  }

  double get _mailboxNameTextSize => mailboxNode.item.isTeamMailboxes
    ? LabelMailboxItemWidgetStyles.labelTeamMailboxTextSize
    : LabelMailboxItemWidgetStyles.labelFolderTextSize;

  Color get _mailboxNameTextColor => mailboxNode.item.isTeamMailboxes
    ? LabelMailboxItemWidgetStyles.labelTeamMailboxTextColor
    : LabelMailboxItemWidgetStyles.labelFolderTextColor;

  FontWeight get _mailboxNameTextFontWeight {
    if (isSelected) {
      return LabelMailboxItemWidgetStyles.labelFolderSelectedFontWeight;
    } else {
      return mailboxNode.item.isTeamMailboxes
        ? LabelMailboxItemWidgetStyles.labelTeamMailboxTextFontWeight
        : LabelMailboxItemWidgetStyles.labelFolderTextFontWeight;
    }
  }
}