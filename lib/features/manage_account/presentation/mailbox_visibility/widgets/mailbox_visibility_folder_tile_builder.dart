import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnExpandFolderActionClick = void Function(MailboxNode);
typedef OnSubscribeMailboxActionClick = void Function(MailboxNode);

class MailBoxVisibilityFolderTileBuilder {
  final MailboxNode _mailboxNode;
  final BuildContext _context;
  final ImagePaths _imagePaths;
  final MailboxNode? lastNode;
  final MailboxActions? mailboxActions;

  OnSubscribeMailboxActionClick? _onSubscribeMailboxActionClick;
  OnExpandFolderActionClick? _onExpandFolderActionClick;
  bool isHoverItem = false;

  MailBoxVisibilityFolderTileBuilder(
    this._context,
    this._imagePaths,
    this._mailboxNode, {
    this.lastNode,
    this.mailboxActions,
  });

  void addOnExpandFolderActionClick(OnExpandFolderActionClick onExpandFolderActionClick) {
    _onExpandFolderActionClick = onExpandFolderActionClick;
  }

  void addOnSubscribeMailboxActionClick(OnSubscribeMailboxActionClick onSubscribeMailboxActionClick) {
    _onSubscribeMailboxActionClick = onSubscribeMailboxActionClick;
  }

  Widget build(BuildContext context) => _buildMailboxItem(context);

  Widget _buildMailboxItem(BuildContext context) {
    if (BuildUtils.isWeb) {
      return Theme(
        data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent),
        child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return InkWell(
                onTap: () {},
                onHover: (value) => setState(() => isHoverItem = value),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: backgroundColorItem),
                  padding: EdgeInsets.only(
                    left: _mailboxNode.item.hasRole() ? 0 : 4,
                    right: 4,
                    top: 8,
                    bottom: 8),
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      _buildLeadingMailboxItem(),
                      const SizedBox(width: 4),
                       Expanded(child: _buildTitleFolderItem()),
                      if (!_mailboxNode.item.hasRole())
                        _buildSubscribeMailboxItem(context, _mailboxNode),
                      const SizedBox(width: 32),
                      ]),
                ),
              );
            }),
      );
    } else {
      return ClipRRect(
          borderRadius: const BorderRadius.all(Radius.circular(14)),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      vertical: _mailboxNode.hasChildren() ? 8 : 15),
                  child: Row(
                      crossAxisAlignment:
                        _mailboxNode.item.isTeamMailboxes
                          ? CrossAxisAlignment.start
                          : CrossAxisAlignment.center,
                      children: [
                        if (_mailboxNode.item.isTeamMailboxes)
                          const SizedBox(width: 16),
                        _buildLeadingMailboxItem(),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTitleFolderItem()),
                        if (!_mailboxNode.item.hasRole())
                          _buildSubscribeMailboxItem(context, _mailboxNode),
                      ]),
                ),
              ]));
    }
  }

  Widget _buildLeadingMailboxItem() {
    if (BuildUtils.isWeb) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        if (_mailboxNode.hasChildren() && _mailboxNode.item.isPersonal)
          Row(
            children: [
              const SizedBox(width: 8),
              buildIconWeb(
                  icon: SvgPicture.asset(
                    _mailboxNode.expandMode == ExpandMode.EXPAND
                      ? _imagePaths.icExpandFolder
                      : _imagePaths.icCollapseFolder,
                    color: _mailboxNode.expandMode == ExpandMode.EXPAND
                      ? AppColor.colorExpandMailbox
                      : AppColor.colorCollapseMailbox,
                    fit: BoxFit.fill),
                  minSize: 12,
                  splashRadius: 10,
                  iconPadding: EdgeInsets.zero,
                  tooltip: _mailboxNode.expandMode == ExpandMode.EXPAND
                    ? AppLocalizations.of(_context).collapse
                    : AppLocalizations.of(_context).expand,
                  onTap: () => _onExpandFolderActionClick?.call(_mailboxNode)),
            ],
          )
        else
          SizedBox(width: _mailboxNode.item.isPersonal ? 32 : 24),
        Transform(
            transform: Matrix4.translationValues(-4.0, 0.0, 0.0),
            child: _buildLeadingIconTeamMailboxes()),
      ]);
    } else {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        if (_mailboxNode.hasChildren())
          Row(
            children: [
              SizedBox(width: _mailboxNode.item.hasRole() ? 0 : 0),
              if (!_mailboxNode.item.isTeamMailboxes)
                buildIconWeb(
                  icon: SvgPicture.asset(
                    _mailboxNode.expandMode == ExpandMode.EXPAND
                      ? _imagePaths.icExpandFolder
                      : _imagePaths.icCollapseFolder,
                    color: _mailboxNode.expandMode == ExpandMode.EXPAND
                      ? AppColor.colorExpandMailbox
                      : AppColor.colorCollapseMailbox,
                    fit: BoxFit.fill),
                    minSize: 12,
                    splashRadius: 10,
                    iconPadding: EdgeInsets.zero,
                    tooltip: _mailboxNode.expandMode == ExpandMode.EXPAND
                      ? AppLocalizations.of(_context).collapse
                      : AppLocalizations.of(_context).expand,
                    onTap: () => _onExpandFolderActionClick?.call(_mailboxNode)),
            ],
          )
        else
          const SizedBox(width: 24),
        _buildLeadingIconTeamMailboxes(),
      ]);
    }
  }

  Widget _buildLeadingIconTeamMailboxes() {
    if (!_mailboxNode.item.isPersonal) {
      return _buildLeadingIconForChildOfTeamMailboxes();
    } else {
      return _buildMailboxIcon();
    }
  }

  Widget _buildLeadingIconForChildOfTeamMailboxes() {
    if (_mailboxNode.item.hasParentId()) {
      return _buildMailboxIcon();
    } else {
      return const SizedBox();
    }
  }

  Color get backgroundColorItem {
    if (BuildUtils.isWeb && isHoverItem) {
      return AppColor.colorBgMailboxSelected;
    } else {
      return Colors.white;
    }
  }

  Widget _buildTitleFolderItem() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _mailboxNode.item.name?.name ?? '',
          maxLines: 1,
          softWrap: CommonTextStyle.defaultSoftWrap,
          overflow: CommonTextStyle.defaultTextOverFlow,
          style: TextStyle(
            fontSize: _mailboxNode.item.isTeamMailboxes ? 16 : 15,
            color: _mailboxNode.item.isSubscribedMailbox
              ? _getColorTextTitleFolderItem()
              : AppColor.colorItemAlreadySelected,
            fontWeight: _mailboxNode.item.isTeamMailboxes
              ? FontWeight.w500
              : FontWeight.normal),
        ),
        if (_mailboxNode.item.isTeamMailboxes)
          Text(
            _mailboxNode.item.emailTeamMailBoxes ?? '',
            maxLines: 1,
            softWrap: CommonTextStyle.defaultSoftWrap,
            overflow: CommonTextStyle.defaultTextOverFlow,
            style: const TextStyle(
              fontSize: 13,
              color: AppColor.colorEmailAddressFull,
              fontWeight: FontWeight.w400),
          ),
      ],
    );
  }

  Color _getColorTextTitleFolderItem() {
    if (_mailboxNode.item.isTeamMailboxes) {
      return Colors.black;
    } else {
      return AppColor.colorNameEmail;
    }
  }

  Widget _buildMailboxIcon() {
    return SvgPicture.asset(_mailboxNode.item.getMailboxIcon(_imagePaths),
        width: BuildUtils.isWeb ? 20 : 24,
        height: BuildUtils.isWeb ? 20 : 24,
        color: !_mailboxNode.item.isSubscribedMailbox
          ? AppColor.colorDeleteContactIcon
          : null,
        fit: BoxFit.fill);
  }

  Widget _buildSubscribeMailboxItem(BuildContext context, MailboxNode _mailboxNode) {
    return InkWell(
      onTap: () => _onSubscribeMailboxActionClick?.call(_mailboxNode),
      child: Text(
        _mailboxNode.item.isSubscribedMailbox
          ? AppLocalizations.of(context).hide
          : AppLocalizations.of(context).show,
        maxLines: 1,
        softWrap: CommonTextStyle.defaultSoftWrap,
        overflow: CommonTextStyle.defaultTextOverFlow,
        style: const TextStyle(
          fontSize: 15, color: Colors.blue, fontWeight: FontWeight.normal),
      ),
    );
  }
}
