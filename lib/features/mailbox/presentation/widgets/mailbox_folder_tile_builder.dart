import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

typedef OnExpandFolderActionClick = void Function(MailboxNode mailboxNode);
typedef OnSelectMailboxFolderClick = void Function(MailboxNode mailboxNode);

class MailBoxFolderTileBuilder {

  final MailboxNode _mailboxNode;
  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final SelectMode selectMode;
  final MailboxDisplayed mailboxDisplayed;

  OnExpandFolderActionClick? _onExpandFolderActionClick;
  OnSelectMailboxFolderClick? _onSelectMailboxFolderClick;

  MailBoxFolderTileBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._mailboxNode,
    {
      this.selectMode = SelectMode.INACTIVE,
      this.mailboxDisplayed = MailboxDisplayed.mailbox,
    }
  );

  void addOnExpandFolderActionClick(OnExpandFolderActionClick onExpandFolderActionClick) {
    this._onExpandFolderActionClick = onExpandFolderActionClick;
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
          borderRadius: BorderRadius.circular(mailboxDisplayed == MailboxDisplayed.mailbox ? 10 : 0),
          color: mailboxDisplayed == MailboxDisplayed.mailbox
            ? selectMode == SelectMode.ACTIVE ? AppColor.mailboxSelectedBackgroundColor : AppColor.mailboxBackgroundColor
            : Colors.white
        ),
        child: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.zero),
          child: Column(children: [
            ListTile(
              onTap: () {
                if (_onSelectMailboxFolderClick != null) {
                  _onSelectMailboxFolderClick!(_mailboxNode);
                }
              },
              contentPadding: EdgeInsets.zero,
              leading: Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: SvgPicture.asset(_imagePaths.icFolderMailbox, width: 28, height: 28, fit: BoxFit.fill)),
              title: _buildTitleFolderItem(),
              trailing: _mailboxNode.hasChildren()
                  ? Padding(
                      padding: EdgeInsets.only(right: mailboxDisplayed == MailboxDisplayed.mailbox ? _responsiveUtils.isMobile(_context) ? 0 : 8 : 0, left: 16),
                      child: IconButton(
                          color: AppColor.primaryColor,
                          icon: SvgPicture.asset(
                              _mailboxNode.expandMode == ExpandMode.EXPAND ? _imagePaths.icExpandFolder : _imagePaths.icFolderArrow,
                              color: selectMode == SelectMode.ACTIVE ? AppColor.mailboxSelectedIconColor : AppColor.colorArrowUserMailbox,
                              fit: BoxFit.fill),
                          onPressed: () {
                            if (_onExpandFolderActionClick != null) {
                              _onExpandFolderActionClick!(_mailboxNode);
                            }
                          }
                      ))
                  : null
            ),
            Padding(
                padding: EdgeInsets.only(left: 45),
                child: Divider(color: AppColor.lineItemListColor, height: 0.5, thickness: 0.2)),
          ])
        )
      )
    );
  }

  Widget _buildTitleFolderItem() {
    return Row(
      children: [
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
          color: selectMode == SelectMode.ACTIVE ? AppColor.backgroundCounterMailboxSelectedColor : AppColor.backgroundCounterMailboxColor),
      child: Text(
        '${_mailboxNode.item.getCountUnReadEmails()} ${AppLocalizations.of(_context).unread_email_notification}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(fontSize: 12, color: AppColor.colorNameEmail),
      ));
  }
}