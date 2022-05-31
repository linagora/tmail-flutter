import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnExpandFolderActionClick = void Function(MailboxNode);
typedef OnOpenMailboxFolderClick = void Function(MailboxNode);
typedef OnSelectMailboxFolderClick = void Function(MailboxNode);
typedef OnMenuActionClick = void Function(RelativeRect, MailboxNode);

class MailBoxFolderTileBuilder {

  final _responsiveUtils = Get.find<ResponsiveUtils>();

  final MailboxNode _mailboxNode;
  final BuildContext _context;
  final ImagePaths _imagePaths;
  final SelectMode allSelectMode;
  final MailboxDisplayed mailboxDisplayed;
  final MailboxNode? lastNode;
  final PresentationMailbox? mailboxNodeSelected;

  OnExpandFolderActionClick? _onExpandFolderActionClick;
  OnOpenMailboxFolderClick? _onOpenMailboxFolderClick;
  OnSelectMailboxFolderClick? _onSelectMailboxFolderClick;
  OnMenuActionClick? _onMenuActionClick;

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
    }
  );

  void addOnExpandFolderActionClick(OnExpandFolderActionClick onExpandFolderActionClick) {
    _onExpandFolderActionClick = onExpandFolderActionClick;
  }

  void addOnOpenMailboxFolderClick(OnOpenMailboxFolderClick onOpenMailboxFolderClick) {
    _onOpenMailboxFolderClick = onOpenMailboxFolderClick;
  }

  void addOnSelectMailboxFolderClick(OnSelectMailboxFolderClick onSelectMailboxFolderClick) {
    _onSelectMailboxFolderClick = onSelectMailboxFolderClick;
  }

  void adOnMenuActionClick(OnMenuActionClick onMenuActionClick) {
    _onMenuActionClick = onMenuActionClick;
  }

  Widget build() {
    if (BuildUtils.isWeb) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return InkWell(
              onTap: () => allSelectMode == SelectMode.ACTIVE
                  ? _onSelectMailboxFolderClick?.call(_mailboxNode)
                  : _onOpenMailboxFolderClick?.call(_mailboxNode),
              onHover: (value) => setState(() => isHoverItem = value),
              child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(BuildUtils.isWeb ? 10 : 0),
                      color: backgroundColorItem),
                  padding: BuildUtils.isWeb
                      ? const EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8)
                      : EdgeInsets.zero,
                  margin: const EdgeInsets.only(bottom: 4),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Row(children: [
                      _buildLeadingMailboxItem(),
                      const SizedBox(width: BuildUtils.isWeb ? 4 : 8),
                      Expanded(child: _buildTitleFolderItem()),
                      const SizedBox(width: 8),
                      _buildTrailingMailboxItem()
                    ]),
                    _buildDivider(),
                  ])
              ),
            );
          });
    } else {
      return InkWell(
        onTap: () => allSelectMode == SelectMode.ACTIVE
            ? _onSelectMailboxFolderClick?.call(_mailboxNode)
            : _onOpenMailboxFolderClick?.call(_mailboxNode),
        child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(BuildUtils.isWeb ? 10 : 0),
                color: backgroundColorItem),
            padding: BuildUtils.isWeb
                ? const EdgeInsets.only(left: 4, right: 4, top: 8, bottom: 8)
                : EdgeInsets.zero,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                _buildLeadingMailboxItem(),
                const SizedBox(width: BuildUtils.isWeb ? 4 : 8),
                Expanded(child: _buildTitleFolderItem()),
                const SizedBox(width: 8),
                _buildTrailingMailboxItem()
              ]),
              _buildDivider(),
            ])
        ),
      );
    }
  }

  Widget _buildLeadingMailboxItem() {
    if (BuildUtils.isWeb) {
      return Row(mainAxisSize: MainAxisSize.min, children: [
        if (_mailboxNode.hasChildren())
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
              onTap: () => _onExpandFolderActionClick?.call(_mailboxNode))
        else
          const SizedBox(width: 24),
        Transform(
            transform: Matrix4.translationValues(-4.0, 0.0, 0.0),
            child: _buildLeadingIcon())
      ]);
    }
    return _buildLeadingIcon();
  }

  Widget _buildTrailingMailboxItem() {
    if (_mailboxNode.hasChildren() && !BuildUtils.isWeb) {
      return buildIconWeb(
          icon: SvgPicture.asset(
              _mailboxNode.expandMode == ExpandMode.EXPAND
                  ? _imagePaths.icExpandFolder
                  : _imagePaths.icCollapseFolder,
              color: _mailboxNode.expandMode == ExpandMode.EXPAND
                  ? AppColor.colorExpandMailbox
                  : AppColor.colorCollapseMailbox,
              fit: BoxFit.fill),
          splashRadius: 10,
          tooltip: _mailboxNode.expandMode == ExpandMode.EXPAND
              ? AppLocalizations.of(_context).collapse
              : AppLocalizations.of(_context).expand,
          onTap: () => _onExpandFolderActionClick?.call(_mailboxNode)
      );
    }

    if (BuildUtils.isWeb && isHoverItem) {
      return _buildMenuIcon();
    }

    if (_mailboxNode.item.getCountUnReadEmails().isNotEmpty
        && mailboxDisplayed == MailboxDisplayed.mailbox) {
      return _buildCounter();
    }

    return const SizedBox(width: 20);
  }

  Widget _buildLeadingIcon() {
    if (BuildUtils.isWeb) {
      return _buildMailboxIcon();
    } else {
      return allSelectMode == SelectMode.ACTIVE
          ? _buildSelectModeIcon()
          : _buildMailboxIcon();
    }
  }

  Widget _buildTitleFolderItem() {
    return Text(
      _mailboxNode.item.name?.name ?? '',
      maxLines: 1,
      overflow: CommonTextStyle.defaultTextOverFlow,
      style: const TextStyle(
          fontSize: 15,
          color: AppColor.colorNameEmail,
          fontWeight: FontWeight.normal),
    );
  }

  Widget _buildCounter() {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: Text(
        _mailboxNode.item.getCountUnReadEmails(),
        maxLines: 1,
        overflow: CommonTextStyle.defaultTextOverFlow,
        style: const TextStyle(
            fontSize: 13,
            color: Colors.black,
            fontWeight: FontWeight.normal),
      ),
    );
  }

  Widget _buildMailboxIcon() {
    return SvgPicture.asset(_mailboxNode.item.getMailboxIcon(_imagePaths));
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
      if (BuildUtils.isWeb) {
        if (mailboxNodeSelected?.id == _mailboxNode.item.id || isHoverItem) {
          return AppColor.colorBgMailboxSelected;
        }
        return _responsiveUtils.isDesktop(_context)
            ? AppColor.colorBgDesktop
            : Colors.white;
      } else {
        return Colors.white;
      }
    }
  }

  Widget _buildDivider() {
    if (lastNode?.item.id != _mailboxNode.item.id && !BuildUtils.isWeb) {
      return Padding(
          padding: EdgeInsets.only(
              left: allSelectMode == SelectMode.ACTIVE ? 50 : 35),
          child: const Divider(
              color: AppColor.lineItemListColor,
              height: 0.5,
              thickness: 0.2
          )
      );
    }
    return const SizedBox.shrink();
  }
}