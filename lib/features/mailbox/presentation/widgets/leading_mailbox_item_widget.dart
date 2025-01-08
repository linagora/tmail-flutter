
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/leading_mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_icon_widget.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class LeadingMailboxItemWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final MailboxNode mailboxNode;
  final SelectMode selectionMode;
  final OnSelectMailboxNodeAction? onSelectMailboxFolderClick;
  final OnClickExpandMailboxNodeAction? onExpandFolderActionClick;

  const LeadingMailboxItemWidget({
    super.key,
    required this.imagePaths,
    required this.mailboxNode,
    this.selectionMode = SelectMode.INACTIVE,
    this.onExpandFolderActionClick,
    this.onSelectMailboxFolderClick,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Visibility.maintain(
        visible: mailboxNode.hasChildren(),
        child: TMailButtonWidget.fromIcon(
          icon: _getExpandIcon(context, imagePaths),
          iconColor: _expandIconColor,
          iconSize: 20,
          padding: const EdgeInsets.all(5),
          backgroundColor: Colors.transparent,
          tooltipMessage: _getExpandTooltipMessage(context),
          onTapActionCallback: () => onExpandFolderActionClick?.call(mailboxNode)
        ),
      ),
      Transform(
        transform: LeadingMailboxItemWidgetStyles.mailboxIconTransform(context),
        child: MailboxIconWidget(
          imagePaths: imagePaths,
          mailboxNode: mailboxNode,
          selectionMode: selectionMode,
          onSelectMailboxFolderClick: onSelectMailboxFolderClick
        )
      ),
    ]);
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
      ? LeadingMailboxItemWidgetStyles.displayColor
      : LeadingMailboxItemWidgetStyles.normalColor;
  }

  String _getExpandTooltipMessage(BuildContext context) {
    return mailboxNode.expandMode == ExpandMode.EXPAND
      ? AppLocalizations.of(context).collapse
      : AppLocalizations.of(context).expand;
  }
}