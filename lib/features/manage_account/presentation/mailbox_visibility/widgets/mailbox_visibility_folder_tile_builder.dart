import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/styles/mailbox_item_widget_styles.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/widgets/mailbox_icon_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/widgets/label_mailbox_visibility_item_widget.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/mailbox_visibility/widgets/mailbox_subscribe_button.dart';

class MailBoxVisibilityFolderTileBuilder extends StatefulWidget {
  final MailboxNode mailboxNode;
  final OnClickExpandMailboxNodeAction onClickExpandMailboxNodeAction;
  final OnClickSubscribeMailboxAction onClickSubscribeMailboxAction;

  const MailBoxVisibilityFolderTileBuilder(
      {Key? key,
      required this.mailboxNode,
      required this.onClickExpandMailboxNodeAction,
      required this.onClickSubscribeMailboxAction})
      : super(key: key);

  @override
  State<MailBoxVisibilityFolderTileBuilder> createState() =>
      _MailBoxVisibilityFolderTileBuilderState();
}

class _MailBoxVisibilityFolderTileBuilderState
    extends State<MailBoxVisibilityFolderTileBuilder> {
  final _imagePaths = Get.find<ImagePaths>();

  final GlobalKey _key = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Material(
      key: _key,
      type: MaterialType.transparency,
      child: InkWell(
        onTap: () {},
        borderRadius: const BorderRadius.all(
          Radius.circular(MailboxItemWidgetStyles.borderRadius),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          height: widget.mailboxNode.item.isTeamMailboxes
              ? MailboxItemWidgetStyles.teamMailboxHeight
              : 40,
          child: Row(children: [
            if (_isIconDisplayed)
              MailboxIconWidget(
                icon: _iconMailbox,
                padding: const EdgeInsetsDirectional.only(end: 8),
                color: _iconMailboxColor,
              ),
            Expanded(
              child: LabelMailboxVisibilityItemWidget(
                itemKey: _key,
                mailboxNode: widget.mailboxNode,
                imagePaths: _imagePaths,
                onClickExpandMailboxNodeAction:
                    widget.onClickExpandMailboxNodeAction,
              ),
            ),
            if (!_mailbox.isDefault)
              MailboxSubscribeButton(
                imagePaths: _imagePaths,
                mailboxNode: widget.mailboxNode,
                onClickSubscribeMailboxAction:
                    widget.onClickSubscribeMailboxAction,
              ),
          ]),
        ),
      ),
    );
  }

  PresentationMailbox get _mailbox => widget.mailboxNode.item;

  bool get _isIconDisplayed => _mailbox.isPersonal || _mailbox.hasParentId();

  String get _iconMailbox => _mailbox.getMailboxIcon(_imagePaths);

  Color get _iconMailboxColor =>
      _mailbox.isSubscribedMailbox || _mailbox.isDefault
          ? AppColor.steelGrayA540
          : AppColor.steelGray200;
}
