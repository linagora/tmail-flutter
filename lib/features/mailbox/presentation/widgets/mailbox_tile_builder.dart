import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';

typedef OnOpenMailboxActionClick = void Function();

class MailboxTileBuilder {

  final PresentationMailbox _presentationMailbox;
  final SelectMode _selectMode;
  final BuildContext _context;
  final ImagePaths _imagePaths;
  final ResponsiveUtils _responsiveUtils;

  OnOpenMailboxActionClick? _onOpenMailboxActionClick;

  MailboxTileBuilder(
    this._context,
    this._imagePaths,
    this._responsiveUtils,
    this._presentationMailbox,
    this._selectMode
  );

  MailboxTileBuilder onOpenMailboxAction(OnOpenMailboxActionClick onOpenMailboxActionClick) {
    _onOpenMailboxActionClick = onOpenMailboxActionClick;
    return this;
  }

  Widget build() {
    return Theme(
      data: ThemeData(
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent),
      child: Container(
        key: Key('mailbox_list_tile'),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: _selectMode== SelectMode.ACTIVE
            ? AppColor.mailboxSelectedBackgroundColor
            : AppColor.mailboxBackgroundColor),
        child: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.zero),
          child: ListTile(
            focusColor: AppColor.primaryLightColor,
            hoverColor: AppColor.primaryLightColor,
            contentPadding: EdgeInsets.zero,
            onTap: () => {
              if (_onOpenMailboxActionClick != null) {
                _onOpenMailboxActionClick!()
              }
            },
            leading: Padding(
              padding: EdgeInsets.only(left: _responsiveUtils.isMobile(_context) ? 40 : 20),
              child: SvgPicture.asset(
                '${_presentationMailbox.getMailboxIcon(_imagePaths)}',
                width: 24,
                height: 24,
                color: _selectMode == SelectMode.ACTIVE
                  ? AppColor.mailboxSelectedIconColor
                  : AppColor.mailboxIconColor,
                fit: BoxFit.fill)),
            title: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                _presentationMailbox.name!.name,
                maxLines: 1,
                overflow:TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: _selectMode == SelectMode.ACTIVE
                    ? AppColor.mailboxSelectedTextColor
                    : AppColor.mailboxTextColor,
                  fontWeight: FontWeight.bold),
              )),
            trailing: Padding(
              padding: EdgeInsets.only(right: _responsiveUtils.isMobile(_context) ? 36 : 24, left: 16),
              child: Text(
                '${_presentationMailbox.getCountUnReadEmails()}',
                maxLines: 1,
                style: TextStyle(
                  fontSize: 15,
                  color: _selectMode == SelectMode.ACTIVE
                    ? AppColor.mailboxSelectedTextNumberColor
                    : AppColor.mailboxTextNumberColor,
                  fontWeight: FontWeight.bold))
            )),
        )
      )
    );
  }
}