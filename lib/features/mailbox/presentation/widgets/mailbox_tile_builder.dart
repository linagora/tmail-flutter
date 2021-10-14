import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/presentation/model/mailbox_displayed.dart';

typedef OnOpenMailboxActionClick = void Function(PresentationMailbox mailbox);

class MailboxTileBuilder {

  final PresentationMailbox _presentationMailbox;
  final SelectMode selectMode;
  final ImagePaths _imagePaths;
  final MailboxDisplayed mailboxDisplayed;

  OnOpenMailboxActionClick? _onOpenMailboxActionClick;

  MailboxTileBuilder(
    this._imagePaths,
    this._presentationMailbox,
    {
      this.selectMode = SelectMode.INACTIVE,
      this.mailboxDisplayed = MailboxDisplayed.mailbox
    }
  );

  void onOpenMailboxAction(OnOpenMailboxActionClick onOpenMailboxActionClick) {
    _onOpenMailboxActionClick = onOpenMailboxActionClick;
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
          borderRadius: BorderRadius.circular(mailboxDisplayed == MailboxDisplayed.mailbox ? 16 : 0),
          color: mailboxDisplayed == MailboxDisplayed.mailbox
            ? selectMode == SelectMode.ACTIVE ? AppColor.mailboxSelectedBackgroundColor : AppColor.mailboxBackgroundColor
            : AppColor.bgMailboxListMail
        ),
        child: MediaQuery(
          data: MediaQueryData(padding: EdgeInsets.zero),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            onTap: () => {
              if (_onOpenMailboxActionClick != null) {
                _onOpenMailboxActionClick!(_presentationMailbox)
              }
            },
            leading: Padding(
              padding: EdgeInsets.only(left: 24),
              child: SvgPicture.asset(
                '${_presentationMailbox.getMailboxIcon(_imagePaths)}',
                width: 24,
                height: 24,
                color: selectMode == SelectMode.ACTIVE
                  ? AppColor.mailboxSelectedIconColor
                  : AppColor.mailboxIconColor,
                fit: BoxFit.fill)),
            title: Padding(
              padding: EdgeInsets.only(left: 8),
              child: Text(
                '${_presentationMailbox.name?.name ?? ''}',
                maxLines: 1,
                overflow:TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 15,
                  color: selectMode == SelectMode.ACTIVE
                    ? AppColor.mailboxSelectedTextColor
                    : AppColor.mailboxTextColor,
                  fontWeight: mailboxDisplayed == MailboxDisplayed.mailbox ? FontWeight.bold : FontWeight.w500),
              )),
            trailing: mailboxDisplayed == MailboxDisplayed.mailbox
                ? Padding(
                    padding: EdgeInsets.only(right: 24, left: 16),
                    child: Text(
                      '${_presentationMailbox.getCountUnReadEmails()}',
                      maxLines: 1,
                      style: TextStyle(
                          fontSize: 15,
                          color: selectMode == SelectMode.ACTIVE
                              ? AppColor.mailboxSelectedTextNumberColor
                              : AppColor.mailboxTextNumberColor,
                          fontWeight: FontWeight.bold)))
                : SizedBox.shrink()
            ),
        )
      )
    );
  }
}