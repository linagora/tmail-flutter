import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:flutter/material.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxSubscribeButton extends StatelessWidget {
  final ImagePaths imagePaths;
  final MailboxNode mailboxNode;
  final OnClickSubscribeMailboxAction onClickSubscribeMailboxAction;

  const MailboxSubscribeButton({
    super.key,
    required this.imagePaths,
    required this.mailboxNode,
    required this.onClickSubscribeMailboxAction,
  });

  @override
  Widget build(BuildContext context) {
    final isSubscribedMailbox = mailboxNode.item.isSubscribedMailbox;
    final appLocalizations = AppLocalizations.of(context);

    return TMailButtonWidget(
      text: isSubscribedMailbox ? appLocalizations.hide : appLocalizations.show,
      textStyle: ThemeUtils.textStyleInter400.copyWith(
        fontSize: 12,
        height: 18 / 12,
        letterSpacing: 0.0,
        color: AppColor.primaryLinShare,
      ),
      icon: mailboxNode.item.isSubscribedMailbox
          ? imagePaths.icHideMailbox
          : imagePaths.icShowMailbox,
      iconAlignment: TextDirection.rtl,
      iconSize: 20,
      iconSpace: 8,
      iconColor: AppColor.primaryLinShare,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      backgroundColor: Colors.transparent,
      onTapActionCallback: () => onClickSubscribeMailboxAction(mailboxNode),
    );
  }
}
