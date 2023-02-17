import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/utils/build_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailBoxFolderTileBuilder {

  final MailboxNode _mailboxNode;
  final BuildContext _context;
  final ImagePaths _imagePaths;
  final SelectMode allSelectMode;
  final MailboxDisplayed mailboxDisplayed;
  final MailboxNode? lastNode;
  final PresentationMailbox? mailboxNodeSelected;
  final MailboxActions? mailboxActions;
  final MailboxId? mailboxIdAlreadySelected;

  OnClickExpandMailboxNodeAction? _onExpandFolderActionClick;
  OnClickOpenMailboxNodeAction? _onOpenMailboxFolderClick;
  OnSelectMailboxNodeAction? _onSelectMailboxFolderClick;
  OnClickOpenMenuMailboxNodeAction? _onMenuActionClick;
  OnDragEmailToMailboxAccepted? _onDragItemAccepted;
  OnLongPressMailboxNodeAction? _onLongPressMailboxNodeAction;
  
  bool isHoverItem = false;

  MailBoxFolderTileBuilder(
    this._context,
    this._imagePaths,
    this._mailboxNode,
    {
      this.allSelectMode = SelectMode.INACTIVE,
      this.mailboxDisplayed = MailboxDisplayed.mailbox,
      this.lastNode,
      this.mailboxNodeSelected,
      this.mailboxActions,
      this.mailboxIdAlreadySelected
    }
  );

  void addOnClickExpandMailboxNodeAction(OnClickExpandMailboxNodeAction onExpandFolderActionClick) {
    _onExpandFolderActionClick = onExpandFolderActionClick;
  }

  void addOnClickOpenMailboxNodeAction(OnClickOpenMailboxNodeAction onOpenMailboxFolderClick) {
    _onOpenMailboxFolderClick = onOpenMailboxFolderClick;
  }

  void addOnSelectMailboxNodeAction(OnSelectMailboxNodeAction onSelectMailboxFolderClick) {
    _onSelectMailboxFolderClick = onSelectMailboxFolderClick;
  }

  void addOnClickOpenMenuMailboxNodeAction(OnClickOpenMenuMailboxNodeAction onMenuActionClick) {
    _onMenuActionClick = onMenuActionClick;
  }

  void addOnDragEmailToMailboxAccepted(OnDragEmailToMailboxAccepted onDragItemAccepted) {
    _onDragItemAccepted = onDragItemAccepted;
  }

  void addOnLongPressMailboxNodeAction(OnLongPressMailboxNodeAction onLongPressMailboxNodeAction) {
    _onLongPressMailboxNodeAction = onLongPressMailboxNodeAction;
  }

  Widget build() {
    if (BuildUtils.isWeb) {
      return DragTarget<List<PresentationEmail>>(
        builder: (context, _, __,) {
          return _buildMailboxItem();
        },
        onAccept: (emails) {
          _onDragItemAccepted?.call(emails, _mailboxNode.item);
        },
      );
    } else {
      return _buildMailboxItem();
    }
  }

  Widget _buildMailboxItem() {
    if (mailboxDisplayed == MailboxDisplayed.mailbox) {
      if (BuildUtils.isWeb) {
        return StatefulBuilder(
            builder: (context, setState) {
              return InkWell(
                onTap: () => _onOpenMailboxFolderClick?.call(_mailboxNode),
                onHover: (value) => setState(() => isHoverItem = value),
                child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: backgroundColorItem),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      crossAxisAlignment: _mailboxNode.item.isTeamMailboxes
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                      children: [
                        _buildLeadingMailboxItem(),
                        const SizedBox(width: 4),
                        Expanded(child: _buildTitleFolderItem()),
                        const SizedBox(width: 8),
                        _buildTrailingItemForMailboxView()
                    ])
                ),
              );
            }
        );
      } else {
        return Material(
          color: Colors.transparent,
          child: InkWell(
            onLongPress: () => _onLongPressMailboxNodeAction?.call(_mailboxNode),
            onTap: () => allSelectMode == SelectMode.ACTIVE
                ? _onSelectMailboxFolderClick?.call(_mailboxNode)
                : _onOpenMailboxFolderClick?.call(_mailboxNode),
            borderRadius: const BorderRadius.all(Radius.circular(8)),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: backgroundColorItem),
              padding: const EdgeInsets.all(8),
              child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: _mailboxNode.item.isTeamMailboxes
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                      children: [
                        _buildLeadingMailboxItem(),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTitleFolderItem()),
                        _buildSelectedIcon(),
                        const SizedBox(width: 8),
                        _buildTrailingItemForMailboxView()
                    ]),
                  ]
              ),
            ),
          ),
        );
      }
    } else {
      return AbsorbPointer(
        absorbing: !_mailboxNode.isActivated,
        child: Opacity(
          opacity: _mailboxNode.isActivated ? 1.0 : 0.3,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _onOpenMailboxFolderClick?.call(_mailboxNode),
              customBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              hoverColor: AppColor.colorMailboxHovered,
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: _mailboxNode.isSelected
                    ? AppColor.colorItemSelected
                    : Colors.transparent,
                  child: Row(children: [
                    _buildLeadingMailboxItem(),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTitleFolderItem()),
                    _buildSelectedIcon()
                  ])
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildLeadingMailboxItem() {
    return Row(children: [
      if (_mailboxNode.hasChildren())
        Row(children: [
          const SizedBox(width: 8),
          buildIconWeb(
            icon: SvgPicture.asset(
              _mailboxNode.expandMode == ExpandMode.EXPAND
                ? _imagePaths.icExpandFolder
                : _imagePaths.icCollapseFolder,
              color: _mailboxNode.item.allowedToDisplay
                ? AppColor.primaryColor
                : AppColor.colorIconUnSubscribedMailbox,
              fit: BoxFit.fill
            ),
            minSize: 12,
            splashRadius: 10,
            iconPadding: EdgeInsets.zero,
            tooltip: _mailboxNode.expandMode == ExpandMode.EXPAND
              ? AppLocalizations.of(_context).collapse
              : AppLocalizations.of(_context).expand,
            onTap: () => _onExpandFolderActionClick?.call(_mailboxNode)
          ),
        ])
      else
        const SizedBox(width: 32),
      Transform(
        transform: Matrix4.translationValues(-4.0, 0.0, 0.0),
        child: _buildLeadingIcon()
      ),
    ]);
  }

  Widget _buildTrailingItemForMailboxView() {
    if (BuildUtils.isWeb) {
      if (isHoverItem) {
        return _buildMenuIcon();
      } else if (_mailboxNode.item.getCountUnReadEmails().isNotEmpty
          && _mailboxNode.item.matchCountingRules()) {
        return Padding(
          padding: const EdgeInsets.only(right: 10),
          child: _buildCounter(),
        );
      } else {
        return const SizedBox(width: 20);
      }
    } else {
      if (_mailboxNode.hasChildren()) {
        return Padding(
          padding: const EdgeInsets.only(right: 12),
          child: Row(
            children: [
              if (_mailboxNode.item.getCountUnReadEmails().isNotEmpty
                && _mailboxNode.item.matchCountingRules())
                  _buildCounter(),
            ],
          ),
        );
      } else if (_mailboxNode.item.getCountUnReadEmails().isNotEmpty
        && _mailboxNode.item.matchCountingRules()) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: _buildCounter(),
          );
      } else {
        return const SizedBox();
      }
    }
  }

  Widget _buildLeadingIcon() {
    if (BuildUtils.isWeb) {
      return _buildLeadingIconTeamMailboxes();
    } else {
      return allSelectMode == SelectMode.ACTIVE
          ? _buildSelectModeIcon()
          : _buildLeadingIconTeamMailboxes();
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
              color: _mailboxNode.item.isTeamMailboxes ? Colors.black : AppColor.colorNameEmail,
              fontWeight: _mailboxNode.item.isTeamMailboxes ? FontWeight.bold : FontWeight.normal),
        ),
        if(_mailboxNode.item.isTeamMailboxes)
          Text(
            _mailboxNode.item.emailTeamMailBoxes ?? '',
            maxLines: 1,
            softWrap: CommonTextStyle.defaultSoftWrap,
            overflow: CommonTextStyle.defaultTextOverFlow,
            style: const TextStyle(
                fontSize: 13,
                color: AppColor.colorEmailAddressFull,
                fontWeight: FontWeight.w400),
          )
      ],
    );
  }

  Widget _buildCounter() {
    return Text(
      _mailboxNode.item.getCountUnReadEmails(),
      maxLines: 1,
      overflow: CommonTextStyle.defaultTextOverFlow,
      style: const TextStyle(
          fontSize: 13,
          color: Colors.black,
          fontWeight: FontWeight.normal),
    );
  }

  Widget _buildMailboxIcon() {
    return SvgPicture.asset(_mailboxNode.item.getMailboxIcon(_imagePaths),
        width: BuildUtils.isWeb ? 20 : 24,
        height: BuildUtils.isWeb ? 20 : 24,
        fit: BoxFit.fill);
  }

  Widget _buildMenuIcon() {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
          onTapDown: (detail) {
            final screenSize = MediaQuery.of(_context).size;
            final offset = detail.globalPosition;
            final position = RelativeRect.fromLTRB(
              offset.dx,
              offset.dy,
              screenSize.width - offset.dx,
              screenSize.height - offset.dy,
            );
            _onMenuActionClick?.call(position, _mailboxNode);
          },
          onTap: () => {},
          child: SvgPicture.asset(_imagePaths.icComposerMenu,
              width: 20,
              height: 20,
              fit: BoxFit.fill)),
    );
  }

  Widget _buildSelectModeIcon() {
    return InkWell(
      onTap: () => _onSelectMailboxFolderClick?.call(_mailboxNode),
      child: SvgPicture.asset(
        _mailboxNode.selectMode == SelectMode.ACTIVE
            ? _imagePaths.icSelected
            : _imagePaths.icUnSelected,
        width: BuildUtils.isWeb ? 20 : 24,
        height: BuildUtils.isWeb ? 20 : 24,
        fit: BoxFit.fill)
    );
  }

  Color get backgroundColorItem {
    if (mailboxDisplayed == MailboxDisplayed.destinationPicker) {
      return Colors.white;
    } else {
      if (mailboxNodeSelected?.id == _mailboxNode.item.id || isHoverItem) {
        return AppColor.colorBgMailboxSelected;
      } else {
        return Colors.transparent;
      }
    }
  }

  Widget _buildSelectedIcon() {
    if (_mailboxNode.item.id == mailboxIdAlreadySelected &&
        mailboxDisplayed == MailboxDisplayed.destinationPicker &&
        (mailboxActions == MailboxActions.select ||
        mailboxActions == MailboxActions.create)) {
      return SvgPicture.asset(
          _imagePaths.icFilterSelected,
          width: 20,
          height: 20,
          fit: BoxFit.fill);
    } else {
      return const SizedBox.shrink();
    }
  }
}