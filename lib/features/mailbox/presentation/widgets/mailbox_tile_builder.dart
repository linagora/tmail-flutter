import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/presentation_mailbox_extension.dart';

typedef OnOpenMailboxActionClick = void Function();

class MailboxTileBuilder {
  final imagePaths = Get.find<ImagePaths>();

  final PresentationMailbox _presentationMailbox;

  OnOpenMailboxActionClick? _onOpenMailboxActionClick;

  MailboxTileBuilder(this._presentationMailbox);

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
          color: _presentationMailbox.selectMode == SelectMode.ACTIVE
            ? AppColor.mailboxSelectedBackgroundColor
            : AppColor.mailboxBackgroundColor),
        child: ListTile(
          focusColor: AppColor.primaryLightColor,
          hoverColor: AppColor.primaryLightColor,
          onTap: () => {
            if (_onOpenMailboxActionClick != null) {
              _onOpenMailboxActionClick!()
            }
          },
          leading: Transform(
            transform: Matrix4.translationValues(20.0, 0.0, 0.0),
            child: SvgPicture.asset(
              '${_presentationMailbox.getMailboxIcon(imagePaths)}',
              width: 24,
              height: 24,
              color: _presentationMailbox.selectMode == SelectMode.ACTIVE
                ? AppColor.mailboxSelectedIconColor
                : AppColor.mailboxIconColor,
              fit: BoxFit.fill)),
          title: Transform(
            transform: Matrix4.translationValues(8.0, 0.0, 0.0),
            child: Text(
              _presentationMailbox.name!.name,
              maxLines: 1,
              overflow:TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 15,
                color: _presentationMailbox.selectMode == SelectMode.ACTIVE
                  ? AppColor.mailboxSelectedTextColor
                  : AppColor.mailboxTextColor,
                fontWeight: FontWeight.bold),
            )),
          trailing: Transform(
            transform: Matrix4.translationValues(-16.0, 0.0, 0.0),
            child: Text(
              '${_presentationMailbox.getCountUnReadEmails()}',
              maxLines: 1,
              style: TextStyle(
                fontSize: 15,
                color: _presentationMailbox.selectMode == SelectMode.ACTIVE
                  ? AppColor.mailboxSelectedTextNumberColor
                  : AppColor.mailboxTextNumberColor,
                fontWeight: FontWeight.bold))
          )),
      )
    );
  }
}