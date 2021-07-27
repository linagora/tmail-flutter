import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_node.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_tree.dart';

typedef OnOpenMailBoxFolderActionClick = void Function(MailboxTree mailboxTree);

class MailBoxFolderTileBuilder extends StatelessWidget {

  final imagePaths = Get.find<ImagePaths>();

  final MailboxNode _mailboxNode;

  final OnOpenMailBoxFolderActionClick? onOpenMailBoxFolderActionClick;

  MailBoxFolderTileBuilder(
    this._mailboxNode,
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
        color: AppColor.mailboxBackgroundColor),
      child: ListTile(
        leading: Transform(
          transform: Matrix4.translationValues(20.0, 0.0, 0.0),
          child: SvgPicture.asset(imagePaths.icMailboxFolder, width: 24, height: 24, color: AppColor.mailboxIconColor, fit: BoxFit.fill)),
        title: Transform(
          transform: Matrix4.translationValues(10.0, 0.0, 0.0),
          child: Text(
            _mailboxNode.item.name!.name,
            maxLines: 1,
            style: TextStyle(fontSize: 15, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold),
          )),
        trailing: Transform(
          transform: Matrix4.translationValues(-16.0, 0.0, 0.0),
          child: _mailboxNode.hasChildren()
            ? SvgPicture.asset(
                imagePaths.icFolderArrow,
                width: 12,
                height: 12,
                color: AppColor.mailboxIconColor,
                fit: BoxFit.fill)
            : SizedBox.shrink()))
    );
  }
}