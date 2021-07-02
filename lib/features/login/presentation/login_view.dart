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
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_input_decoration_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

class LoginView extends GetWidget<LoginController> {

  final loginController = Get.find<LoginController>();
  final imagePaths = Get.find<ImagePaths>();
  final responsiveUtils = Get.find<ResponsiveUtils>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColor.primaryLightColor,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              reverse: true,
              child: Padding(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildSlogan(context),
                      _buildLoginMessage(context),
                      _buildUrlInput(context),
                      _buildUserNameInput(context),
                      _buildPasswordInput(context),
                      _buildLoginButton(context),
                    ],
                  ),
                ),
              )
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSlogan(BuildContext context) {
    return SloganBuilder()
      .setSloganText(AppLocalizations.of(context).login_text_slogan)
      .setSloganTextAlign(TextAlign.center)
      .setSloganTextStyle(TextStyle(color: AppColor.primaryColor, fontSize: 16, fontWeight: FontWeight.w700))
      .setLogo(imagePaths.icTMailLogo)
      .build();
  }

  Widget _buildLoginMessage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24, top: 60),
      child: Container(
        width: responsiveUtils.getWidthLoginTextField(context),
        child: CenterTextBuilder()
          .key(Key('login_message'))
          .text(AppLocalizations.of(context).login_text_login_to_continue)
          .textStyle(TextStyle(color: AppColor.primaryColor))
          .build()));
  }

  Widget _buildUrlInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Container(
        width: responsiveUtils.getWidthLoginTextField(context),
        child: TextFieldBuilder()
          .key(Key('login_url_input'))
          .onChange((value) => loginController.setUrlText(value))
          .textInputAction(TextInputAction.next)
          .textDecoration(LoginInputDecorationBuilder()
            .setLabelText(AppLocalizations.of(context).prefix_https)
            .setPrefixText(AppLocalizations.of(context).prefix_https)
            .build())
          .build()));
  }

  Widget _buildUserNameInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: Container(
        width: responsiveUtils.getWidthLoginTextField(context),
        child: TextFieldBuilder()
          .key(Key('login_username_input'))
          .onChange((value) => loginController.setUserNameText(value))
          .textInputAction(TextInputAction.next)
          .textDecoration(LoginInputDecorationBuilder()
            .setLabelText(AppLocalizations.of(context).username)
            .setHintText(AppLocalizations.of(context).username)
            .build())
          .build()));
  }

  Widget _buildPasswordInput(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 40),
      child: Container(
        width: responsiveUtils.getWidthLoginTextField(context),
        child: TextFieldBuilder()
          .key(Key('login_password_input'))
          .onChange((value) => loginController.setPasswordText(value))
          .textInputAction(TextInputAction.done)
          .textDecoration(LoginInputDecorationBuilder()
            .setLabelText(AppLocalizations.of(context).password)
            .setHintText(AppLocalizations.of(context).password)
            .build())
          .build()));
  }

  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 16),
      child: SizedBox(
        key: Key('login_confirm_button'),
        width: responsiveUtils.getWidthLoginButton(),
        height: 48,
        child: ElevatedButton(
          style: ButtonStyle(
            foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => Colors.white),
            backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) => AppColor.buttonColor),
            shape: MaterialStateProperty.all(RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(80),
              side: BorderSide(width: 0, color: AppColor.buttonColor)))),
          child: Text(AppLocalizations.of(context).login, style: TextStyle(fontSize: 16, color: Colors.white)),
          onPressed: () {
            KeyboardUtils.hideKeyboard(context);
            loginController.handleLoginPressed();
          }),
      )
    );
  }
}