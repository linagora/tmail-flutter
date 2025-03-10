import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/tmail_button_widget.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/extensions/presentation_mailbox_extension.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailBoxVisibilityFolderTileBuilder extends StatelessWidget {

  final MailboxNode _mailboxNode;
  final ImagePaths _imagePaths;
  final OnClickExpandMailboxNodeAction? onClickExpandMailboxNodeAction;
  final OnClickSubscribeMailboxAction? onClickSubscribeMailboxAction;

  const MailBoxVisibilityFolderTileBuilder(
    this._imagePaths,
    this._mailboxNode, {
    Key? key,
    this.onClickExpandMailboxNodeAction,
    this.onClickSubscribeMailboxAction
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {},
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: Row(
            children: [
              _buildLeadingMailboxItem(context),
              Expanded(child: _buildTitleFolderItem(context)),
              if (!_mailboxNode.item.isDefault)
                _buildSubscribeButton(context),
              const SizedBox(width: 32),
            ]
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingMailboxItem(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Visibility.maintain(
          visible: _mailboxNode.hasChildren() && _mailboxNode.item.isPersonal,
          child: TMailButtonWidget.fromIcon(
            icon: _getExpandIcon(context, _imagePaths),
            iconColor: _mailboxNode.item.allowedToDisplay
              ? Colors.black
              : AppColor.colorIconUnSubscribedMailbox,
            padding: const EdgeInsets.all(5),
            iconSize: 20,
            backgroundColor: Colors.transparent,
            tooltipMessage: _mailboxNode.expandMode == ExpandMode.EXPAND
              ? AppLocalizations.of(context).collapse
              : AppLocalizations.of(context).expand,
            onTapActionCallback: () => onClickExpandMailboxNodeAction?.call(_mailboxNode)
          ),
        ),
        if (!_mailboxNode.item.isTeamMailboxes)
          _buildMailboxIcon(context),
      ]
    );
  }

  String _getExpandIcon(BuildContext context, ImagePaths imagePaths) {
    if (_mailboxNode.expandMode == ExpandMode.EXPAND) {
      return imagePaths.icArrowBottom;
    } else {
      return DirectionUtils.isDirectionRTLByLanguage(context)
        ? imagePaths.icArrowLeft
        : imagePaths.icArrowRight;
    }
  }

  Widget _buildTitleFolderItem(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _mailboxNode.item.getDisplayName(context),
          maxLines: 1,
          softWrap: CommonTextStyle.defaultSoftWrap,
          overflow: CommonTextStyle.defaultTextOverFlow,
          style: TextStyle(
            fontSize: _mailboxNode.item.isTeamMailboxes ? 16 : 14,
            color: _mailboxNode.item.allowedToDisplay
              ? Colors.black
              : AppColor.colorTitleAUnSubscribedMailbox,
            fontWeight: _mailboxNode.item.isTeamMailboxes
              ? FontWeight.w500
              : FontWeight.normal),
        ),
        if (_mailboxNode.item.isTeamMailboxes)
          Text(
            _mailboxNode.item.emailTeamMailBoxes,
            maxLines: 1,
            softWrap: CommonTextStyle.defaultSoftWrap,
            overflow: CommonTextStyle.defaultTextOverFlow,
            style: const TextStyle(
              fontSize: 13,
              color: AppColor.colorEmailAddressFull,
              fontWeight: FontWeight.normal),
          ),
      ],
    );
  }

  Widget _buildMailboxIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: SvgPicture.asset(
        _mailboxNode.item.getMailboxIcon(_imagePaths),
        width: 20,
        height: 20,
        colorFilter: _mailboxNode.item.allowedToDisplay
          ? AppColor.primaryColor.asFilter()
          : AppColor.colorIconUnSubscribedMailbox.asFilter(),
        fit: BoxFit.fill
      ),
    );
  }

  Widget _buildSubscribeButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onClickSubscribeMailboxAction?.call(_mailboxNode),
        borderRadius: const BorderRadius.all(Radius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Text(
            _mailboxNode.item.isSubscribedMailbox
              ? AppLocalizations.of(context).hide
              : AppLocalizations.of(context).show,
            maxLines: 1,
            softWrap: CommonTextStyle.defaultSoftWrap,
            overflow: CommonTextStyle.defaultTextOverFlow,
            style: const TextStyle(
              fontSize: 15,
              color: AppColor.primaryColor,
              fontWeight: FontWeight.normal
            )
          ),
        ),
      ),
    );
  }
}
