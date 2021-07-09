// LinShare is an open source filesharing software, part of the LinPKI software
// suite, developed by Linagora.
//
// Copyright (C) 2020 LINAGORA
//
// This program is free software: you can redistribute it and/or modify it under the
// terms of the GNU Affero General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later version,
// provided you comply with the Additional Terms applicable for LinShare software by
// Linagora pursuant to Section 7 of the GNU Affero General Public License,
// subsections (b), (c), and (e), pursuant to which you must notably (i) retain the
// display in the interface of the “LinShare™” trademark/logo, the "Libre & Free" mention,
// the words “You are using the Free and Open Source version of LinShare™, powered by
// Linagora © 2009–2020. Contribute to Linshare R&D by subscribing to an Enterprise
// offer!”. You must also retain the latter notice in all asynchronous messages such as
// e-mails sent with the Program, (ii) retain all hypertext links between LinShare and
// http://www.linshare.org, between linagora.com and Linagora, and (iii) refrain from
// infringing Linagora intellectual property rights over its trademarks and commercial
// brands. Other Additional Terms apply, see
// <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf>
// for more details.
// This program is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE. See the GNU Affero General Public License for
// more details.
// You should have received a copy of the GNU Affero General Public License and its
// applicable Additional Terms for LinShare along with this program. If not, see
// <http://www.gnu.org/licenses/> for the GNU Affero General Public License version
//  3 and <http://www.linshare.org/licenses/LinShare-License_AfferoGPL-v3.pdf> for
//  the Additional Terms applicable to LinShare software.

import 'dart:ui';

import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:model/mailbox/mailbox.dart';
import 'package:model/mailbox/select_mode.dart';
import 'package:tmail_ui_user/features/mailbox/domain/extensions/mailbox_role_extension.dart';

typedef OnOpenMailboxActionClick = void Function();

class MailboxTileBuilder {
  final imagePath = Get.find<ImagePaths>();

  final Mailbox _mailbox;

  OnOpenMailboxActionClick? _onOpenMailboxActionClick;

  MailboxTileBuilder(this._mailbox);

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
          color: _mailbox.selectMode == SelectMode.ACTIVE
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
              _mailbox.role.getIconMailbox(imagePath),
              width: 24,
              height: 24,
              color: _mailbox.selectMode == SelectMode.ACTIVE
                ? AppColor.mailboxSelectedIconColor
                : AppColor.mailboxIconColor,
              fit: BoxFit.fill)),
          title: Transform(
            transform: Matrix4.translationValues(8.0, 0.0, 0.0),
            child: Text(
              _mailbox.getNameMailbox(),
              maxLines: 1,
              style: TextStyle(
                fontSize: 15,
                color: _mailbox.selectMode == SelectMode.ACTIVE
                  ? AppColor.mailboxSelectedTextColor
                  : AppColor.mailboxTextColor,
                fontWeight: FontWeight.w500),
            )),
          trailing: Transform(
            transform: Matrix4.translationValues(-16.0, 0.0, 0.0),
            child: Text(
              '${_mailbox.getCountUnReadEmails()}',
              maxLines: 1,
              style: TextStyle(
                fontSize: 15,
                color: _mailbox.selectMode == SelectMode.ACTIVE
                  ? AppColor.mailboxSelectedTextNumberColor
                  : AppColor.mailboxTextNumberColor,
                fontWeight: FontWeight.w500))
          )),
      )
    );
  }
}