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

import 'package:model/model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tmail_ui_user/features/login/data/utils/login_constant.dart';
import 'package:tmail_ui_user/features/login/domain/repository/credential_repository.dart';

class CredentialRepositoryImpl extends CredentialRepository {

  final SharedPreferences sharedPreferences;

  CredentialRepositoryImpl(this.sharedPreferences);

  @override
  Future<Uri> getBaseUrl() async {
    return Uri.parse(sharedPreferences.getString(LoginConstant.keyBaseUrl) ?? '');
  }

  @override
  Future saveBaseUrl(Uri baseUrl) async {
    await sharedPreferences.setString(LoginConstant.keyBaseUrl, baseUrl.origin);
  }

  @override
  Future removeBaseUrl() async {
    await sharedPreferences.remove(LoginConstant.keyBaseUrl);
  }

  @override
  Future<Password> getPassword() async {
    return Password(sharedPreferences.getString(LoginConstant.keyPassword) ?? '');
  }

  @override
  Future removePassword() async {
    await sharedPreferences.remove(LoginConstant.keyPassword);
  }

  @override
  Future savePassword(Password password) async {
    await sharedPreferences.setString(LoginConstant.keyPassword, password.value);
  }

  @override
  Future<UserName> getUserName() async {
    return UserName(sharedPreferences.getString(LoginConstant.keyUserName) ?? '');
  }

  @override
  Future removeUserName() async {
    await sharedPreferences.remove(LoginConstant.keyUserName);
  }

  @override
  Future saveUserName(UserName userName) async {
    await sharedPreferences.setString(LoginConstant.keyUserName, userName.userName);
  }
}