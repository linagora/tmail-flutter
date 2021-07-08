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

import 'dart:ui' show Color;

import 'package:flutter/material.dart';

extension AppColor on Color {
  static const primaryColor = Color(0xFF837DFF);
  static const primaryDarkColor = Color(0xFF1C1C1C);
  static const primaryLightColor = Color(0xFFFFFFFF);
  static const baseTextColor = Color(0xFF7E869B);
  static const textFieldTextColor = Color(0xFF7E869B);
  static const textFieldLabelColor = Color(0xFF7E869B);
  static const textFieldHintColor = Color(0xFF757575);
  static const textFieldBorderColor = Color(0xfff2f1fd);
  static const textFieldFocusedBorderColor = Color(0xFF837DFF);
  static const textFieldErrorBorderColor = Color(0xffFF5858);
  static const buttonColor = Color(0xFF837DFF);
  static const appColor = Color(0xFF3840F7);
  static const nameUserColor = Color(0xFF182952);
  static const emailUserColor = Color(0xFF7E869B);
  static const userInformationBackgroundColor = Color(0xFFF5F5F7);
  static const searchBorderColor = Color(0xFFEAEAEA);
  static const searchHintTextColor = Color(0xFF7E869B);
  static const mailboxSelectedBackgroundColor = Color(0xFFE6E5FF);
  static const mailboxBackgroundColor = Color(0xFFFFFFFF);
  static const mailboxSelectedTextColor = Color(0xFF3840F7);
  static const mailboxTextColor = Color(0xFF182952);
  static const mailboxSelectedTextNumberColor = Color(0xFF182952);
  static const mailboxTextNumberColor = Color(0xFF837DFF);
  static const mailboxSelectedIconColor = Color(0xFF3840F7);
  static const mailboxIconColor = Color(0xFF7E869B);
  static const storageBackgroundColor = Color(0xFFF5F5F7);
  static const storageTitleColor = Color(0xFF7E869B);
  static const storageMaxSizeColor = Color(0xFF101D43);
  static const storageUseSizeColor = Color(0xFF2D0CFF);
  static const myFolderTitleColor = Color(0xFF7E869B);
}
