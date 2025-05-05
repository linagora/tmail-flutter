import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailboxExpandButton extends StatelessWidget {
  final MailboxNode mailboxNode;
  final ImagePaths imagePaths;
  final OnClickExpandMailboxNodeAction? onExpandFolderActionClick;

  const MailboxExpandButton({
    super.key,
    required this.mailboxNode,
    required this.imagePaths,
    required this.onExpandFolderActionClick,
  });

  @override
  Widget build(BuildContext context) {
    return TMailButtonWidget.fromIcon(
      icon: _getExpandIcon(context, imagePaths),
      iconColor: _expandIconColor,
      iconSize: 20,
      padding: const EdgeInsets.all(5),
      backgroundColor: Colors.transparent,
      tooltipMessage: _getExpandTooltipMessage(context),
      onTapActionCallback: () => onExpandFolderActionClick?.call(mailboxNode),
    );
  }

  String _getExpandIcon(BuildContext context, ImagePaths imagePaths) {
    if (mailboxNode.expandMode == ExpandMode.EXPAND) {
      return imagePaths.icArrowBottom;
    } else {
      return DirectionUtils.isDirectionRTLByLanguage(context)
          ? imagePaths.icArrowLeft
          : imagePaths.icArrowRight;
    }
  }

  Color get _expandIconColor {
    return mailboxNode.item.allowedToDisplay
        ? Colors.black
        : AppColor.steelGray200;
  }

  String _getExpandTooltipMessage(BuildContext context) {
    return mailboxNode.expandMode == ExpandMode.EXPAND
        ? AppLocalizations.of(context).collapse
        : AppLocalizations.of(context).expand;
  }
}
