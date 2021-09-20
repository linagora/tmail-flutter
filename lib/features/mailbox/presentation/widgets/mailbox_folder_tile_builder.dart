import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';

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
          borderRadius: BorderRadius.circular( mailboxDisplayed == MailboxDisplayed.mailbox ? 16 : 0),
          color: mailboxDisplayed == MailboxDisplayed.mailbox
            ? selectMode == SelectMode.ACTIVE ? AppColor.mailboxSelectedBackgroundColor : AppColor.mailboxBackgroundColor
            : AppColor.bgMailboxListMail
        ),
        child: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.zero),
          child: ListTile(
            onTap: () {
              if (_onSelectMailboxFolderClick != null) {
                _onSelectMailboxFolderClick!(_mailboxNode);
              }
            },
            contentPadding: EdgeInsets.zero,
            leading: Padding(
              padding: EdgeInsets.only(left: 26),
              child: SvgPicture.asset(
                _imagePaths.icMailboxFolder,
                width: 24,
                height: 24,
                color: selectMode == SelectMode.ACTIVE
                  ? AppColor.mailboxSelectedIconColor
                  : AppColor.mailboxIconColor,
                fit: BoxFit.fill)),
            title: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                _mailboxNode.item.name!.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: selectMode == SelectMode.ACTIVE
                    ? AppColor.mailboxSelectedTextColor
                    : AppColor.mailboxTextColor,
                  fontWeight: mailboxDisplayed == MailboxDisplayed.mailbox ? FontWeight.bold : FontWeight.w500),
              )),
            trailing: Padding(
              padding: EdgeInsets.only(
                  right: mailboxDisplayed == MailboxDisplayed.mailbox
                    ? _responsiveUtils.isMobile(_context) ? 0 : 8
                    : 0,
                  left: 16),
              child: _mailboxNode.hasChildren()
                ? IconButton(
                    color: AppColor.primaryColor,
                    icon: SvgPicture.asset(
                      _mailboxNode.expandMode == ExpandMode.EXPAND ? _imagePaths.icExpandFolder : _imagePaths.icFolderArrow,
                      color: selectMode == SelectMode.ACTIVE
                          ? AppColor.mailboxSelectedIconColor
                          : AppColor.mailboxIconColor,
                      fit: BoxFit.fill),
                    onPressed: () {
                      if (_onExpandFolderActionClick != null) {
                        _onExpandFolderActionClick!(_mailboxNode);
                      }
                    }
                  )
                : SizedBox.shrink())
          )
        )
      )
    );
  }
}