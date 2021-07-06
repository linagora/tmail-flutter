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

import 'package:core/core.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/domain/model/account/password.dart';
import 'package:tmail_ui_user/features/login/domain/model/account/user_name.dart';
import 'package:tmail_ui_user/features/login/domain/state/authentication_user_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/state/login_state.dart';

class LoginController extends GetxController {

  final AuthenticationInteractor _authenticationInteractor;
  final DynamicUrlInterceptors _dynamicUrlInterceptors;

  LoginController(this._authenticationInteractor, this._dynamicUrlInterceptors);

  var loginState = LoginState.IDLE.obs;

  String _urlText = '';
  String _userNameText = '';
  String _passwordText = '';

  void setUrlText(String url) => _urlText = url.formatURLValid();

  void setUserNameText(String userName) => _userNameText = userName;

  void setPasswordText(String password) => _passwordText = password;

  Uri _parseUri(String url) => Uri.parse(url);

  UserName _parseUserName(String userName) => UserName(userName);

  Password _parsePassword(String password) => Password(password);

  void handleLoginPressed() {
    _loginAction(_parseUri(_urlText), _parseUserName(_userNameText), _parsePassword(_passwordText));
  }

  void _loginAction(Uri baseUrl, UserName userName, Password password) async {
    loginState(LoginState.LOADING);
    await _authenticationInteractor.execute(baseUrl, userName, password)
      .then((response) => response.fold(
        (failure) => failure is AuthenticationUserFailure ? _loginFailureAction(failure) : null,
        (success) => success is AuthenticationUserViewState ? _loginSuccessAction(success) : null));
  }

  void _loginSuccessAction(AuthenticationUserViewState success) {
    loginState(LoginState.SUCCESS);
    _dynamicUrlInterceptors.changeBaseUrl(_urlText);
    Get.snackbar('Login Success', 'User: ${success.user}');
  }

  void _loginFailureAction(AuthenticationUserFailure failure) {
    loginState(LoginState.FAILURE);
    Get.snackbar('Login Failure', '${failure.exception}');
  }
}