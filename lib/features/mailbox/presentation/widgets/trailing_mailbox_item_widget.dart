
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
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

  const TrailingMailboxItemWidget({
    super.key,
    required this.mailboxNode,
    this.isItemHovered = false,
    this.onMenuActionClick,
  });

  @override
  Widget build(BuildContext context) {
    final imagePaths = Get.find<ImagePaths>();

    if (PlatformInfo.isWeb) {
      if (isItemHovered) {
        return Padding(
          padding: TrailingMailboxItemWidgetStyles.menuIconPadding,
          child: InkWell(
            onTapDown: (detail) {
              final screenSize = MediaQuery.of(context).size;
              final offset = detail.globalPosition;
              final position = RelativeRect.fromLTRB(
                offset.dx,
                offset.dy,
                screenSize.width - offset.dx,
                screenSize.height - offset.dy,
              );
              onMenuActionClick?.call(position, mailboxNode);
            },
            onTap: () => {},
            child: SvgPicture.asset(
              imagePaths.icComposerMenu,
              width: TrailingMailboxItemWidgetStyles.menuIconSize,
              height: TrailingMailboxItemWidgetStyles.menuIconSize,
              fit: BoxFit.fill
            )
          ),
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