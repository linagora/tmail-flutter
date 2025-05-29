import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/expand_mode_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxExpandButton extends StatelessWidget {
  final GlobalKey itemKey;
  final MailboxNode mailboxNode;
  final ImagePaths imagePaths;
  final OnClickExpandMailboxNodeAction? onExpandFolderActionClick;

  const MailboxExpandButton({
    super.key,
    required this.itemKey,
    required this.mailboxNode,
    required this.imagePaths,
    required this.onExpandFolderActionClick,
  });

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget.fromIcon(
      icon: mailboxNode.expandMode.getIcon(
        imagePaths,
        DirectionUtils.isDirectionRTLByLanguage(context),
      ),
      iconColor: _expandIconColor,
      iconSize: PlatformInfo.isMobile ? 17 : 20,
      margin: PlatformInfo.isMobile
        ? const EdgeInsetsDirectional.only(start: 8)
        : null,
      padding: EdgeInsets.all(PlatformInfo.isMobile ? 3 : 5),
      backgroundColor: Colors.transparent,
      tooltipMessage: mailboxNode.expandMode.getTooltipMessage(AppLocalizations.of(context)),
      onTapActionCallback: () => onExpandFolderActionClick?.call(mailboxNode, itemKey),
    );
  }

  Color get _expandIconColor {
    return mailboxNode.item.allowedToDisplay
        ? Colors.black
        : AppColor.steelGray200;
  }
}
