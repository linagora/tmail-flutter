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
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class StorageWidgetBuilder {
  final imagePath = Get.find<ImagePaths>();
  final BuildContext _context;

  StorageWidgetBuilder(this._context);

  Widget build() {
    return Container(
      key: Key('storage_widget'),
      padding: EdgeInsets.only(left: 40, top: 16, bottom: 20, right: 40),
      color: AppColor.storageBackgroundColor,
      alignment: Alignment.bottomLeft,
      height: 112,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(_context).storage,
            maxLines: 1,
            style: TextStyle(fontSize: 12, color: AppColor.storageTitleColor, fontWeight: FontWeight.w500)),
          Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: RichText(
              text: TextSpan(
                style: TextStyle(fontSize: 16, color: AppColor.storageMaxSizeColor, fontWeight: FontWeight.w700),
                children: [
                  TextSpan(
                    text: '299.6MB',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColor.storageUseSizeColor)),
                  TextSpan(
                    text: ' / unlimited',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColor.storageMaxSizeColor))
                ]
              )
            )
          )
        ]
      )
    );
  }
}