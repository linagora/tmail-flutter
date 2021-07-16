import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tmail_ui_user/features/mailbox/domain/model/mailbox_tree.dart';

typedef OnOpenMailBoxFolderActionClick = void Function(MailboxTree mailboxTree);

class MailBoxFolderTileBuilder extends StatelessWidget {

  final ImagePaths imagePath;
  final MailboxTree mailboxTree;
  final OnOpenMailBoxFolderActionClick? onOpenMailBoxFolderActionClick;

  MailBoxFolderTileBuilder({
    required this.mailboxTree,
    required this.imagePath,
    this.onOpenMailBoxFolderActionClick,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: Container(
        key: Key('mailbox_folder_tile'),
        alignment: Alignment.center,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColor.mailboxBackgroundColor),
        child: ListTile(
          leading: Transform(
            transform: Matrix4.translationValues(20.0, 0.0, 0.0),
            child: SvgPicture.asset(imagePath.icMailboxFolder, width: 24, height: 24, color: AppColor.mailboxIconColor, fit: BoxFit.fill)),
          title: Transform(
            transform: Matrix4.translationValues(10.0, 0.0, 0.0),
            child: Text(
              mailboxTree.item.getNameMailbox(),
              maxLines: 1,
              style: TextStyle(fontSize: 15, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold),
            )),
          trailing: Transform(
            transform: Matrix4.translationValues(-16.0, 0.0, 0.0),
            child: mailboxTree.isParent()
              ? SvgPicture.asset(
                  mailboxTree.isExpand() ? imagePath.icExpandFolder : imagePath.icFolderArrow,
                  width: mailboxTree.isExpand() ? 8 : 12,
                  height: mailboxTree.isExpand() ? 8 : 12,
                  color: AppColor.mailboxIconColor,
                  fit: BoxFit.fill)
              : SizedBox.shrink()))
      )
    );
  }
}