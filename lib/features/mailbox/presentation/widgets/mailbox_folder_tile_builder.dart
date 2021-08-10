import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

typedef OnOpenMailBoxFolderActionClick = void Function(MailboxTree mailboxTree);

class MailBoxFolderTileBuilder extends StatelessWidget {

  final MailboxNode _mailboxNode;
  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;
  final SelectMode _selectMode;

  final OnOpenMailBoxFolderActionClick? onOpenMailBoxFolderActionClick;

  MailBoxFolderTileBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._mailboxNode,
    this._selectMode,
    {
      this.onOpenMailBoxFolderActionClick
    }
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      key: Key('mailbox_folder_tile'),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: _selectMode== SelectMode.ACTIVE
          ? AppColor.mailboxSelectedBackgroundColor
          : AppColor.mailboxBackgroundColor),
      child: MediaQuery(
        data: MediaQueryData(padding: EdgeInsets.zero),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Padding(
            padding: EdgeInsets.only(left: _responsiveUtils.isMobile(_context) ? 40 : 34),
            child: SvgPicture.asset(
              _imagePaths.icMailboxFolder,
              width: 24,
              height: 24,
              color: _selectMode == SelectMode.ACTIVE
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
                color: _selectMode == SelectMode.ACTIVE
                  ? AppColor.mailboxSelectedTextColor
                  : AppColor.mailboxTextColor,
                fontWeight: FontWeight.bold),
            )),
          trailing: Padding(
            padding: EdgeInsets.only(right: _responsiveUtils.isMobile(_context) ? 36 : 8, left: 16),
            child: _mailboxNode.hasChildren()
              ? SvgPicture.asset(
                  _imagePaths.icFolderArrow,
                  width: 12,
                  height: 12,
                  color: _selectMode == SelectMode.ACTIVE
                    ? AppColor.mailboxSelectedIconColor
                    : AppColor.mailboxIconColor,
                  fit: BoxFit.fill)
              : SizedBox.shrink())
        )
      )
    );
  }
}