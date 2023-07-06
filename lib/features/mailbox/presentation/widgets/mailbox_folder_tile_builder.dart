import 'package:core/presentation/extensions/color_extension.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/presentation/utils/style_utils.dart';
import 'package:core/presentation/views/button/icon_button_web.dart';
import 'package:core/presentation/views/text/text_overflow_builder.dart';
import 'package:core/utils/direction_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/email/presentation_email.dart';
import 'package:model/mailbox/expand_mode.dart';
import 'package:model/mailbox/presentation_mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_actions.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/utils/mailbox_method_action_define.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class MailBoxFolderTileBuilder {

  final MailboxNode _mailboxNode;
  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils? responsiveUtils;
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
      this.responsiveUtils,
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
    if (responsiveUtils?.isWebDesktop(_context) == true && mailboxDisplayed == MailboxDisplayed.mailbox) {
      return DragTarget<List<PresentationEmail>>(
        builder: (_, __, ___) => _buildMailboxItem(_context),
        onAccept: (emails) => _onDragItemAccepted?.call(emails, _mailboxNode.item),
      );
    } else {
      return _buildMailboxItem(_context);
    }
  }

  Widget _buildMailboxItem(BuildContext context) {
    if (mailboxDisplayed == MailboxDisplayed.mailbox) {
      if (PlatformInfo.isWeb) {
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
                      children: [
                        _buildLeadingMailboxItem(context),
                        const SizedBox(width: 4),
                        Expanded(child: _buildTitleFolderItem(context)),
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
                      children: [
                        _buildLeadingMailboxItem(context),
                        const SizedBox(width: 8),
                        Expanded(child: _buildTitleFolderItem(context)),
                        _buildSelectedIcon(),
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
              onTap: () => !_isSelectActionNoValid
                ? _onOpenMailboxFolderClick?.call(_mailboxNode)
                : null,
              customBorder: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
              hoverColor: AppColor.colorMailboxHovered,
              child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  color: _mailboxNode.isSelected
                    ? AppColor.colorItemSelected
                    : Colors.transparent,
                  child: Row(children: [
                    _buildLeadingMailboxItem(context),
                    const SizedBox(width: 8),
                    Expanded(child: _buildTitleFolderItem(context, showTrailingItem: false)),
                    _buildSelectedIcon(),
                    const SizedBox(width: 8),
                  ])
              ),
            ),
          ),
        ),
      );
    }
  }

  Widget _buildLeadingMailboxItem(BuildContext context) {
    return Row(children: [
      if (_mailboxNode.hasChildren())
        Row(children: [
          const SizedBox(width: 8),
          buildIconWeb(
            icon: SvgPicture.asset(
              _mailboxNode.expandMode == ExpandMode.EXPAND
                ? _imagePaths.icArrowBottom
                : DirectionUtils.isDirectionRTLByLanguage(context) ? _imagePaths.icArrowLeft : _imagePaths.icArrowRight,
              colorFilter: _mailboxNode.item.allowedToDisplay
                ? AppColor.primaryColor.asFilter()
                : AppColor.colorIconUnSubscribedMailbox.asFilter(),
              fit: BoxFit.fill,
            ),
            splashRadius: 12,
            iconPadding: EdgeInsets.zero,
            minSize: 15,
            tooltip: _mailboxNode.expandMode == ExpandMode.EXPAND
              ? AppLocalizations.of(_context).collapse
              : AppLocalizations.of(_context).expand,
            onTap: () => _onExpandFolderActionClick?.call(_mailboxNode)
          ),
        ])
      else
        const SizedBox(width: 32),
      Transform(
        transform: Matrix4.translationValues(
          DirectionUtils.isDirectionRTLByLanguage(context) ? 0.0 : -4.0,
          0.0,
          0.0
        ),
        child: _buildLeadingIcon()
      ),
    ]);
  }

  Widget _buildTrailingItemForMailboxView(BuildContext context) {
    if (PlatformInfo.isWeb) {
      if (isHoverItem) {
        return _buildMenuIcon(context);
      } else if (_mailboxNode.item.getCountUnReadEmails().isNotEmpty
          && _mailboxNode.item.matchCountingRules()) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 10),
          child: _buildCounter(),
        );
      } else {
        return const SizedBox(width: 20);
      }
    } else {
      if (_mailboxNode.hasChildren()) {
        return Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
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
            padding: const EdgeInsetsDirectional.only(start: 12),
            child: _buildCounter(),
          );
      } else {
        return const SizedBox();
      }
    }
  }

  Widget _buildLeadingIcon() {
    if (PlatformInfo.isWeb) {
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

  Widget _buildTitleFolderItem(BuildContext context, {bool showTrailingItem = true}) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextOverflowBuilder(
                _mailboxNode.item.getDisplayName(context),
                style: TextStyle(
                  fontSize: _mailboxNode.item.isTeamMailboxes ? 16 : 15,
                  color: _mailboxNode.item.isTeamMailboxes ? Colors.black : AppColor.colorNameEmail,
                  fontWeight: _mailboxNode.item.isTeamMailboxes ? FontWeight.bold : FontWeight.normal),
              ),
            ),
            if (showTrailingItem)
              _buildTrailingItemForMailboxView(context)
          ],
        ),
        if(_mailboxNode.item.isTeamMailboxes)
          TextOverflowBuilder(
            (_mailboxNode.item.emailTeamMailBoxes ?? ''),
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
        width: PlatformInfo.isWeb ? 20 : 24,
        height: PlatformInfo.isWeb ? 20 : 24,
        fit: BoxFit.fill);
  }

  Widget _buildMenuIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(start: 8),
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
        width: PlatformInfo.isWeb ? 20 : 24,
        height: PlatformInfo.isWeb ? 20 : 24,
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
    if (_isSelectActionNoValid) {
      return SvgPicture.asset(
        _imagePaths.icSelectedSB,
        width: 20,
        height: 20,
        fit: BoxFit.fill);
    } else {
      return const SizedBox.shrink();
    }
  }

  bool get _isSelectActionNoValid => _mailboxNode.item.id == mailboxIdAlreadySelected &&
    mailboxDisplayed == MailboxDisplayed.destinationPicker &&
    (
      mailboxActions == MailboxActions.select ||
      mailboxActions == MailboxActions.create ||
      mailboxActions == MailboxActions.moveEmail
    );
}