import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnExpandFolderActionClick = void Function(MailboxNode);
typedef OnOpenMailboxFolderClick = void Function(MailboxNode);
typedef OnSelectMailboxFolderClick = void Function(MailboxNode);

class MailBoxFolderTileBuilder {

  final MailboxNode _mailboxNode;
  final BuildContext _context;
  final ImagePaths _imagePaths;
  final SelectMode allSelectMode;
  final MailboxDisplayed mailboxDisplayed;

  OnExpandFolderActionClick? _onExpandFolderActionClick;
  OnOpenMailboxFolderClick? _onOpenMailboxFolderClick;
  OnSelectMailboxFolderClick? _onSelectMailboxFolderClick;

  MailBoxFolderTileBuilder(
    this._context,
    this._imagePaths,
    this._mailboxNode,
    {
      this.allSelectMode = SelectMode.INACTIVE,
      this.mailboxDisplayed = MailboxDisplayed.mailbox,
    }
  );

  void addOnExpandFolderActionClick(OnExpandFolderActionClick onExpandFolderActionClick) {
    this._onExpandFolderActionClick = onExpandFolderActionClick;
  }

  void addOnOpenMailboxFolderClick(OnOpenMailboxFolderClick onOpenMailboxFolderClick) {
    this._onOpenMailboxFolderClick = onOpenMailboxFolderClick;
  }

  void addOnSelectMailboxFolderClick(OnSelectMailboxFolderClick onSelectMailboxFolderClick) {
    this._onSelectMailboxFolderClick = onSelectMailboxFolderClick;
  }

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: Container(
        key: Key('mailbox_folder_tile'),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(0),
          color: Colors.white
        ),
        child: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.zero),
          child: Column(children: [
            ListTile(
              onTap: () => allSelectMode == SelectMode.ACTIVE
                  ? _onSelectMailboxFolderClick?.call(_mailboxNode)
                  : _onOpenMailboxFolderClick?.call(_mailboxNode),
              contentPadding: EdgeInsets.zero,
              leading: allSelectMode == SelectMode.ACTIVE
                  ? _buildSelectModeIcon()
                  : _buildMailboxIcon(),
              title: _buildTitleFolderItem(),
              trailing: _mailboxNode.hasChildren()
                  ? Padding(
                      padding: EdgeInsets.only(right: 0, left: 16),
                      child: IconButton(
                          padding: EdgeInsets.zero,
                          color: AppColor.primaryColor,
                          icon: SvgPicture.asset(
                              _mailboxNode.expandMode == ExpandMode.EXPAND ? _imagePaths.icExpandFolder : _imagePaths.icFolderArrow,
                              color: AppColor.colorArrowUserMailbox,
                              fit: BoxFit.fill),
                          onPressed: () => _onExpandFolderActionClick?.call(_mailboxNode)
                      ))
                  : null
            ),
            Padding(
                padding: EdgeInsets.only(left: allSelectMode == SelectMode.ACTIVE ? 50 : 45),
                child: Divider(color: AppColor.lineItemListColor, height: 0.5, thickness: 0.2)),
          ])
        )
      )
    );
  }

  Widget _buildTitleFolderItem() {
    return Row(
      children: [
        if (allSelectMode == SelectMode.ACTIVE)
          Transform(
              transform: Matrix4.translationValues(-16.0, 0.0, 0.0),
              child: _buildMailboxIcon()),
        Expanded(child: Transform(
          transform: Matrix4.translationValues(-10.0, 0.0, 0.0),
          child: Text(
            '${_mailboxNode.item.name?.name ?? ''}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 15,
              color: AppColor.colorNameEmail),
          ))),
        if (_mailboxNode.item.getCountUnReadEmails().isNotEmpty && mailboxDisplayed == MailboxDisplayed.mailbox)
          !_mailboxNode.hasChildren()
             ? _buildCounter()
             : Transform(
                  transform: Matrix4.translationValues(40.0, 0.0, 0.0),
                  child: _buildCounter())
      ],
    );
  }

  Widget _buildCounter() {
    return Container(
      margin: EdgeInsets.only(left: 8, right: _mailboxNode.hasChildren() ? 0 : 16),
      padding: EdgeInsets.only(left: 8, right: 8, top: 2.5, bottom: 2.5),
      decoration:BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: AppColor.backgroundCounterMailboxColor),
      child: Text(
        '${_mailboxNode.item.getCountUnReadEmails()} ${AppLocalizations.of(_context).unread_email_notification}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: AppColor.colorNameEmail),
      ));
  }

  Widget _buildMailboxIcon() {
    return Padding(
        padding: EdgeInsets.only(
            left: allSelectMode == SelectMode.ACTIVE ? 0 : 8,
            right: allSelectMode == SelectMode.ACTIVE ? 8 : 0),
        child: SvgPicture.asset(
            _imagePaths.icFolderMailbox,
            width: 28,
            height: 28,
            fit: BoxFit.fill
        )
    );
  }

  Widget _buildSelectModeIcon() {
    return Material(
        borderRadius: BorderRadius.circular(10),
        color: Colors.transparent,
        child: IconButton(
            padding: EdgeInsets.zero,
            icon: SvgPicture.asset(
                _mailboxNode.selectMode == SelectMode.ACTIVE ? _imagePaths.icSelectedV2 : _imagePaths.icUnSelectedV2,
                width: 20,
                height: 20,
                fit: BoxFit.fill),
            onPressed: () => _onSelectMailboxFolderClick?.call(_mailboxNode)
        )
    );
  }
}