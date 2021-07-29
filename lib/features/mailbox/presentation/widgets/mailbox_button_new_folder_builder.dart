import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

typedef OnOpenMailboxNewFolderActionClick = void Function();

class MailboxNewFolderTileBuilder {

  final BuildContext _context;
  final ResponsiveUtils _responsiveUtils;

  String? _icon;
  String? _name;

  OnOpenMailboxNewFolderActionClick? _onOpenMailboxFolderActionClick;

  MailboxNewFolderTileBuilder(this._context, this._responsiveUtils);

  MailboxNewFolderTileBuilder addIcon(String icon) {
    _icon = icon;
    return this;
  }

  MailboxNewFolderTileBuilder addName(String name) {
    _name = name;
    return this;
  }

  MailboxNewFolderTileBuilder onOpenMailboxFolderAction(OnOpenMailboxNewFolderActionClick onOpenMailboxFolderActionClick) {
    _onOpenMailboxFolderActionClick = onOpenMailboxFolderActionClick;
    return this;
  }

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: Container(
        key: Key('mailbox_new_folder_tile'),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppColor.mailboxBackgroundColor),
        child: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.zero),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => {
              if (_onOpenMailboxFolderActionClick != null) {
                _onOpenMailboxFolderActionClick!()
              }
            },
            leading: Padding(
              padding: EdgeInsets.only(left: _responsiveUtils.isMobile(_context) ? 42 : 34),
              child: _icon != null
                ? SvgPicture.asset(_icon!, width: 24, height: 24, color: AppColor.mailboxIconColor, fit: BoxFit.fill)
                : SizedBox.shrink()),
            title: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                _name ?? '',
                maxLines: 1,
                style: TextStyle(fontSize: 15, color: AppColor.mailboxTextColor, fontWeight: FontWeight.bold),
              )),
          )
        )
      )
    );
  }
}