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

typedef OnOpenMailBoxNewFolderActionClick = void Function();

class MailBoxNewFolderTileBuilder {
  final imagePath = Get.find<ImagePaths>();

  String? _icon;
  String? _name;

  OnOpenMailBoxNewFolderActionClick? _onOpenMailBoxFolderActionClick;

  MailBoxNewFolderTileBuilder();

  MailBoxNewFolderTileBuilder addIcon(String icon) {
    _icon = icon;
    return this;
  }

  MailBoxNewFolderTileBuilder addName(String name) {
    _name = name;
    return this;
  }

  MailBoxNewFolderTileBuilder onOpenMailBoxFolderAction(OnOpenMailBoxNewFolderActionClick onOpenMailBoxFolderActionClick) {
    _onOpenMailBoxFolderActionClick = onOpenMailBoxFolderActionClick;
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
        child: ListTile(
          onTap: () => {
            if (_onOpenMailBoxFolderActionClick != null) {
              _onOpenMailBoxFolderActionClick!()
            }
          },
          leading: Transform(
            transform: Matrix4.translationValues(20.0, 0.0, 0.0),
            child: _icon != null
              ? SvgPicture.asset(_icon!, width: 24, height: 24, color: AppColor.mailboxIconColor, fit: BoxFit.fill)
              : SizedBox.shrink()),
          title: Transform(
            transform: Matrix4.translationValues(10.0, 0.0, 0.0),
            child: Text(
              _name ?? '',
              maxLines: 1,
              style: TextStyle(fontSize: 15, color: AppColor.mailboxTextColor, fontWeight: FontWeight.w500),
            )),
        )
      )
    );
  }
}