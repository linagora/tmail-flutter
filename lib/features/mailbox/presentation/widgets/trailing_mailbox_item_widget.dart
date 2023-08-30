
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/trailing_mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/count_of_emails_widget.dart';

class TrailingMailboxItemWidget extends StatelessWidget {

  final MailboxNode mailboxNode;
  final bool isItemHovered;
  final OnClickOpenMenuMailboxNodeAction? onMenuActionClick;

  final _imagePaths = Get.find<ImagePaths>();

  TrailingMailboxItemWidget({
    super.key,
    required this.mailboxNode,
    this.isItemHovered = false,
    this.onMenuActionClick,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (isItemHovered) {
        return TMailButtonWidget.fromIcon(
          margin: TrailingMailboxItemWidgetStyles.menuIconMargin,
          icon: _imagePaths.icComposerMenu,
          iconSize: TrailingMailboxItemWidgetStyles.menuIconSize,
          padding: TrailingMailboxItemWidgetStyles.menuIconPadding,
          backgroundColor: TrailingMailboxItemWidgetStyles.menuIconBackgroundColor,
          onTapActionAtPositionCallback: (position) => onMenuActionClick?.call(position, mailboxNode),
        );
      } else if (mailboxNode.item.countUnreadEmails > 0 && mailboxNode.item.allowedToDisplayCountOfUnreadEmails) {
        return Padding(
          padding: TrailingMailboxItemWidgetStyles.countEmailsPadding,
          child: CountOfEmailsWidget(value: mailboxNode.item.countUnReadEmailsAsString),
        );
      } else if (mailboxNode.item.countTotalEmails > 0 && mailboxNode.item.allowedToDisplayCountOfTotalEmails) {
        return Padding(
          padding: TrailingMailboxItemWidgetStyles.countEmailsPadding,
          child: CountOfEmailsWidget(value: mailboxNode.item.countTotalEmailsAsString),
        );
      } else {
        return const SizedBox();
      }
    } else {
      if (mailboxNode.item.countUnreadEmails > 0 && mailboxNode.item.allowedToDisplayCountOfUnreadEmails) {
        return Padding(
          padding: TrailingMailboxItemWidgetStyles.countEmailsPadding,
          child: CountOfEmailsWidget(value: mailboxNode.item.countUnReadEmailsAsString),
        );
      } else if (mailboxNode.item.countTotalEmails > 0 && mailboxNode.item.allowedToDisplayCountOfTotalEmails) {
        return Padding(
          padding: TrailingMailboxItemWidgetStyles.countEmailsPadding,
          child: CountOfEmailsWidget(value: mailboxNode.item.countTotalEmailsAsString),
        );
      } else {
        return const SizedBox();
      }
    }
  }
}