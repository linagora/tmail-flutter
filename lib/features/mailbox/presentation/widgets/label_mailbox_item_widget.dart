import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:flutter/material.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/label_mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/empty_mailbox_popup_dialog_widget.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_expand_button.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/trailing_mailbox_item_widget.dart';

class LabelMailboxItemWidget extends StatelessWidget {

  final GlobalKey itemKey;
  final ResponsiveUtils responsiveUtils;
  final ImagePaths imagePaths;
  final MailboxNode mailboxNode;
  final bool showTrailing;
  final bool isItemHovered;
  final bool isSelected;
  final OnClickOpenMenuMailboxNodeAction? onMenuActionClick;
  final OnEmptyMailboxActionCallback? onEmptyMailboxActionCallback;
  final OnClickExpandMailboxNodeAction? onClickExpandMailboxNodeAction;

  const LabelMailboxItemWidget({
    super.key,
    required this.itemKey,
    required this.mailboxNode,
    required this.responsiveUtils,
    required this.imagePaths,
    this.showTrailing = true,
    this.isItemHovered = false,
    this.isSelected = false,
    this.onMenuActionClick,
    this.onEmptyMailboxActionCallback,
    this.onClickExpandMailboxNodeAction,
  });

  @override
  Widget build(BuildContext context) {
    final displayNameWidget = TextOverflowBuilder(
      mailboxNode.item.getDisplayName(context),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: LabelMailboxItemWidgetStyles.labelFolderTextSize,
        color: LabelMailboxItemWidgetStyles.labelFolderTextColor,
        fontWeight: _mailboxNameTextFontWeight,
      ),
    );

    final nameWithExpandIcon = Row(
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
            onExpandFolderActionClick: onClickExpandMailboxNodeAction,
          ),
      ],
    );

    if (!showTrailing) {
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
                fontWeight: LabelMailboxItemWidgetStyles.labelFolderTextFontWeight,
              ),
            ),
          ],
        );
      } else {
        return nameWithExpandIcon;
      }
    }

    final trailingWidget = TrailingMailboxItemWidget(
      mailboxNode: mailboxNode,
      responsiveUtils: responsiveUtils,
      imagePaths: imagePaths,
      isItemHovered: isItemHovered,
      onMenuActionClick: onMenuActionClick,
    );

    final childWidget = Row(
      children: [
        Expanded(child: nameWithExpandIcon),
        if (responsiveUtils.isWebDesktop(context) &&
            mailboxNode.item.allowedHasEmptyAction)
          EmptyMailboxPopupDialogWidget(
            mailboxNode: mailboxNode,
            onEmptyMailboxActionCallback: (mailboxNode) =>
                onEmptyMailboxActionCallback?.call(mailboxNode),
          ),
        trailingWidget,
      ],
    );

    if (mailboxNode.item.isTeamMailboxes) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          childWidget,
          TextOverflowBuilder(
            mailboxNode.item.emailTeamMailBoxes,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontSize: LabelMailboxItemWidgetStyles.labelFolderTextSize,
              color: LabelMailboxItemWidgetStyles.teamMailboxEmailTextColor,
              fontWeight: LabelMailboxItemWidgetStyles.labelFolderTextFontWeight,
            ),
          ),
        ],
      );
    } else {
      return childWidget;
    }
  }

  FontWeight get _mailboxNameTextFontWeight {
    if (isSelected || mailboxNode.item.isTeamMailboxes) {
      return LabelMailboxItemWidgetStyles.labelFolderSelectedFontWeight;
    } else {
      return LabelMailboxItemWidgetStyles.labelFolderTextFontWeight;
    }
  }
}