import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class LoginRobot extends CoreRobot {
  final appLocalizations = AppLocalizations();

  LoginRobot(super.$);

  Future<void> grantNotificationPermission(NativeAutomator nativeAutomator) async {
    if (await nativeAutomator.isPermissionDialogVisible(timeout: const Duration(seconds: 5))) {
      await nativeAutomator.grantPermissionWhenInUse();
    }
  }

  Future<void> tapOnUseCompanyServer() async {
    await $(appLocalizations.useCompanyServer).tap();
  }

  Future<void> enterEmail(String email) async {
    final finder = $(#dns_lookup_input_form).$(TextField);
    final isTextFieldFocused = finder
      .which<TextField>((view) => view.focusNode?.hasFocus ?? false)
      .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterText(email);
  }

  Future<void> enterHostUrl(String url) async {
    final finder = $(#base_url_form).$(TextField);
    final isTextFieldFocused = finder
      .which<TextField>((view) => view.focusNode?.hasFocus ?? false)
      .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterText(url);
  }

  Future<void> tapOnNextButton() async {
    await $(appLocalizations.next).tap();
  }

  Future<void> enterBasicAuthEmail(String email) async {
    final finder = $(#login_username_input).$(TextField);
    final isTextFieldFocused = finder
      .which<TextField>((view) => view.focusNode?.hasFocus ?? false)
      .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterText(email);
  }

  Future<void> enterBasicAuthPassword(String password) async {
    final finder = $(#login_password_input).$(TextField);
    final isTextFieldFocused = finder
      .which<TextField>((view) => view.focusNode?.hasFocus ?? false)
      .exists;
    if (!isTextFieldFocused) {
      await finder.tap();
    }
    await finder.enterText(password);
  }

  Future<void> loginBasicAuth() async {
    await $(#loginSubmitForm).tap();
  }
}