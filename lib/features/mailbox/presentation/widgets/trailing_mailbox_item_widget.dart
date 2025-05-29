
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/trailing_mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/count_of_emails_widget.dart';

class TrailingMailboxItemWidget extends StatelessWidget {

  final MailboxNode mailboxNode;
  final ImagePaths imagePaths;
  final ResponsiveUtils responsiveUtils;
  final bool isItemHovered;
  final OnClickOpenMenuMailboxNodeAction? onMenuActionClick;

  const TrailingMailboxItemWidget({
    super.key,
    required this.mailboxNode,
    required this.imagePaths,
    required this.responsiveUtils,
    this.isItemHovered = false,
    this.onMenuActionClick,
  });

  @override
  Widget build(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (isItemHovered) {
        return TMailButtonWidget.fromIcon(
          margin: responsiveUtils.isDesktop(context) && mailboxNode.item.allowedHasEmptyAction
            ? EdgeInsets.zero
            : TrailingMailboxItemWidgetStyles.menuIconMargin,
          icon: imagePaths.icMoreVertical,
          iconSize: TrailingMailboxItemWidgetStyles.menuIconSize,
          padding: TrailingMailboxItemWidgetStyles.menuIconPadding,
          backgroundColor: TrailingMailboxItemWidgetStyles.menuIconBackgroundColor,
          onTapActionAtPositionCallback: (position) => onMenuActionClick?.call(position, mailboxNode),
        );
      } else if (responsiveUtils.isDesktop(context) && mailboxNode.item.allowedHasEmptyAction) {
        return const SizedBox();
      } else if (mailboxNode.item.allowedToDisplayCountOfUnreadEmails) {
        return Padding(
          padding: PlatformInfo.isMobile
            ? TrailingMailboxItemWidgetStyles.mobileCountEmailsPadding
            : TrailingMailboxItemWidgetStyles.countEmailsPadding,
          child: CountOfEmailsWidget(value: mailboxNode.item.countUnReadEmailsAsString),
        );
      } else if (mailboxNode.item.allowedToDisplayCountOfTotalEmails) {
        return Padding(
          padding: PlatformInfo.isMobile
            ? TrailingMailboxItemWidgetStyles.mobileCountEmailsPadding
            : TrailingMailboxItemWidgetStyles.countEmailsPadding,
          child: CountOfEmailsWidget(value: mailboxNode.item.countTotalEmailsAsString),
        );
      } else {
        return const SizedBox();
      }
    } else {
      if (mailboxNode.item.allowedToDisplayCountOfUnreadEmails) {
        return Padding(
          padding: PlatformInfo.isMobile
            ? TrailingMailboxItemWidgetStyles.mobileCountEmailsPadding
            : TrailingMailboxItemWidgetStyles.countEmailsPadding,
          child: CountOfEmailsWidget(value: mailboxNode.item.countUnReadEmailsAsString),
        );
      } else if (mailboxNode.item.allowedToDisplayCountOfTotalEmails) {
        return Padding(
          padding: PlatformInfo.isMobile
            ? TrailingMailboxItemWidgetStyles.mobileCountEmailsPadding
            : TrailingMailboxItemWidgetStyles.countEmailsPadding,
          child: CountOfEmailsWidget(value: mailboxNode.item.countTotalEmailsAsString),
        );
      } else {
        return const SizedBox();
      }
    }
  }
}