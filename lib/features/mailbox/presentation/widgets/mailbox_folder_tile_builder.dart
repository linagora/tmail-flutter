import 'package:core/core.dart';
import 'package:flutter/foundation.dart';
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

  bool isHoverIcon = false;

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

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: Container(
        key: const Key('mailbox_folder_tile'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(kIsWeb ? 10 : 0),
          color: backgroundColorItem
        ),
        padding: kIsWeb ? const EdgeInsets.only(left: 8, right: 4) : EdgeInsets.zero,
        child: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.zero),
          child: Column(children: [
            ListTile(
              hoverColor: Colors.transparent,
              onTap: () => allSelectMode == SelectMode.ACTIVE
                  ? _onSelectMailboxFolderClick?.call(_mailboxNode)
                  : _onOpenMailboxFolderClick?.call(_mailboxNode),
              contentPadding: EdgeInsets.zero,
              leading: _buildLeadingIcon(),
              title: _buildTitleFolderItem(),
              trailing: _mailboxNode.hasChildren()
                  ? Transform(
                      transform: Matrix4.translationValues(8.0, 0.0, 0.0),
                      child: buildIconWeb(
                          icon: SvgPicture.asset(
                              _mailboxNode.expandMode == ExpandMode.EXPAND ? _imagePaths.icExpandFolder : _imagePaths.icCollapseFolder,
                              color: _mailboxNode.expandMode == ExpandMode.EXPAND ? AppColor.colorExpandMailbox : AppColor.colorCollapseMailbox,
                              fit: BoxFit.fill),
                          splashRadius: 10,
                          tooltip: _mailboxNode.expandMode == ExpandMode.EXPAND ? AppLocalizations.of(_context).collapse : AppLocalizations.of(_context).expand,
                          onTap: () => _onExpandFolderActionClick?.call(_mailboxNode)))
                  : _mailboxNode.item.getCountUnReadEmails().isNotEmpty
                        && mailboxDisplayed == MailboxDisplayed.mailbox
                        && !_mailboxNode.hasChildren()
                    ? const SizedBox(width: 40)
                    : const SizedBox.shrink()
            ),
            if (lastNode?.item.id != _mailboxNode.item.id && !kIsWeb)
              Padding(
                  padding: EdgeInsets.only(left: allSelectMode == SelectMode.ACTIVE ? 50 : 35),
                  child: const Divider(color: AppColor.lineItemListColor, height: 0.5, thickness: 0.2)),
          ])
        )
      )
    );
  }

  Widget _buildLeadingIcon() {
    if (kIsWeb) {
      return _mailboxNode.selectMode == SelectMode.ACTIVE ? _buildSelectModeIcon() : _buildMailboxIcon();
    } else {
      return allSelectMode == SelectMode.ACTIVE ? _buildSelectModeIcon() : _buildMailboxIcon();
    }
  }

  Widget _buildTitleFolderItem() {
    return Row(
      children: [
        if (allSelectMode == SelectMode.ACTIVE)
          Transform(
              transform: Matrix4.translationValues(-24.0, 0.0, 0.0),
              child: _buildMailboxIcon()),
        Expanded(child: Transform(
          transform: Matrix4.translationValues(allSelectMode == SelectMode.ACTIVE ? -16.0 : -20.0, 0.0, 0.0),
          child: Text(
            _mailboxNode.item.name?.name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 15, color: AppColor.colorNameEmail, fontWeight: FontWeight.normal),
          ))),
        if (_mailboxNode.item.getCountUnReadEmails().isNotEmpty && mailboxDisplayed == MailboxDisplayed.mailbox)
          Transform(transform: Matrix4.translationValues(25.0, 0.0, 0.0), child: _buildCounter())
      ],
    );
  }

  Widget _buildCounter() {
    return Text(
      _mailboxNode.item.getCountUnReadEmails(),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(fontSize: 13, color: Colors.black, fontWeight: FontWeight.normal),
    );
  }

  Widget _buildMailboxIcon() {
    if (kIsWeb) {
      return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return InkWell(
                onTap: () {},
                onHover: (value) => setState(() => isHoverIcon = value),
                child: isHoverIcon
                  ? _buildSelectModeIcon()
                  : SvgPicture.asset(_mailboxNode.item.getMailboxIcon(_imagePaths), width: 28, height: 28, fit: BoxFit.fill)
            );
          });
    } else {
      return SvgPicture.asset(_mailboxNode.item.getMailboxIcon(_imagePaths), width: 28, height: 28, fit: BoxFit.fill);
    }
  }

  Widget _buildSelectModeIcon() {
    return Container(
      color: Colors.transparent,
      child: Transform(
          transform: Matrix4.translationValues(kIsWeb ? -8.0 : -10.0, 0.0, 0.0),
          child: buildIconWeb(
              icon: SvgPicture.asset(
                  _mailboxNode.selectMode == SelectMode.ACTIVE ? _imagePaths.icSelected : _imagePaths.icUnSelected,
                  width: kIsWeb ? 20 : 24,
                  height: kIsWeb ? 20 : 24,
                  fit: BoxFit.fill),
              onTap: () => _onSelectMailboxFolderClick?.call(_mailboxNode))),
    );
  }

  Color get backgroundColorItem {
    if (mailboxDisplayed == MailboxDisplayed.destinationPicker) {
      return Colors.white;
    } else {
      if (kIsWeb) {
        if (mailboxNodeSelected?.id == _mailboxNode.item.id) {
          return AppColor.colorBgMailboxSelected;
        }
        return _responsiveUtils.isDesktop(_context) ? AppColor.colorBgDesktop : Colors.white;
      } else {
        return Colors.white;
      }
    }
  }
}