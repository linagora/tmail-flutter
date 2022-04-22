
import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnOpenMailboxNewFolderActionClick = void Function();

class MailboxNewFolderTileBuilder {

  String? _icon;
  String? _name;

  OnOpenMailboxNewFolderActionClick? _onOpenMailboxFolderActionClick;

  MailboxNewFolderTileBuilder();

  void addIcon(String icon) {
    _icon = icon;
  }

  void addName(String name) {
    _name = name;
  }

  void onOpenMailboxFolderAction(OnOpenMailboxNewFolderActionClick onOpenMailboxFolderActionClick) {
    _onOpenMailboxFolderActionClick = onOpenMailboxFolderActionClick;
  }

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: Container(
        key: const Key('mailbox_new_folder_tile'),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColor.mailboxBackgroundColor),
        child: MediaQuery(
          data: const MediaQueryData(padding: EdgeInsets.zero),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => {
              if (_onOpenMailboxFolderActionClick != null) {
                _onOpenMailboxFolderActionClick!()
              }
            },
            leading: Padding(
              padding: const EdgeInsets.only(left: 34),
              child: _icon != null
                ? SvgPicture.asset(_icon!, width: 24, height: 24, color: AppColor.mailboxIconColor, fit: BoxFit.fill)
                : const SizedBox.shrink()),
            title: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                _name ?? '',
                maxLines: 1,
                style: const TextStyle(fontSize: 15, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold),
              )),
          )
        )
      )
    );
  }
}