
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_icon_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';

class MailboxIconWidget extends StatelessWidget {

  final ImagePaths imagePaths;
  final MailboxNode mailboxNode;
  final SelectMode selectionMode;
  final OnSelectMailboxNodeAction? onSelectMailboxFolderClick;
  final EdgeInsetsGeometry? padding;

  const MailboxIconWidget({
    super.key,
    required this.mailboxNode,
    required this.imagePaths,
    this.selectionMode = SelectMode.INACTIVE,
    this.padding,
    this.onSelectMailboxFolderClick,
  });

  @override
  Widget build(BuildContext context) {
    Widget? item;

    if (_isSelectionActivatedOnMobile) {
      item = InkWell(
        onTap: () => onSelectMailboxFolderClick?.call(mailboxNode),
        child: SvgPicture.asset(
          _getSelectionIcon(imagePaths),
          width: MailboxIconWidgetStyles.iconSize,
          height: MailboxIconWidgetStyles.iconSize,
          fit: BoxFit.fill,
        )
      );
    } else if (mailboxNode.item.isPersonal || mailboxNode.item.hasParentId()) {
      item = SvgPicture.asset(
        mailboxNode.item.getMailboxIcon(imagePaths),
        width: MailboxIconWidgetStyles.iconSize,
        height: MailboxIconWidgetStyles.iconSize,
        fit: BoxFit.fill,
      );
    }

    if (padding != null) {
      return Padding(
        padding: padding!,
        child: item ?? const SizedBox.shrink(),
      );
    } else {
      return item ?? const SizedBox.shrink();
    }
  }

  bool get _isSelectionActivatedOnMobile => PlatformInfo.isMobile && selectionMode == SelectMode.ACTIVE;

  String _getSelectionIcon(ImagePaths imagePaths) {
    return mailboxNode.selectMode == SelectMode.ACTIVE
      ? imagePaths.icSelected
      : imagePaths.icUnSelected;
  }
}