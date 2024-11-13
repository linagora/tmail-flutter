import 'package:core/presentation/views/text/type_ahead_form_field_builder.dart';
import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/login/domain/model/recent_login_username.dart';
import 'package:tmail_ui_user/features/login/presentation/login_view.dart';
import 'package:tmail_ui_user/features/login/presentation/widgets/login_text_input_builder.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';

import '../base/core_robot.dart';

class LoginRobot extends CoreRobot {
  LoginRobot(super.$);

  Future<void> grantNotificationPermission(NativeAutomator nativeAutomator) async {
    if (await nativeAutomator.isPermissionDialogVisible(timeout: const Duration(seconds: 5))) {
      await nativeAutomator.grantPermissionWhenInUse();
    }
  }

  Future<void> tapOnUseCompanyServer() async {
    await $.pumpAndSettle();
    await $(AppLocalizations().useCompanyServer).tap();
  }

  Future<void> enterEmail(String email) async {
    final finder = $(LoginView).$(TextField);
    await finder.enterText(email);
    await $('Next').tap();
  }

  Future<void> enterHostUrl(String url) async {
    final finder = $(LoginView).$(TextField);
    await finder.enterText(url);
    await $('Next').tap();
  }

  Future<void> enterBasicAuthEmail(String email) async {
    await $(LoginView)
      .$(TypeAheadFormFieldBuilder<RecentLoginUsername>)
      .$(TextField)
      .enterText(email);
  }

  Future<void> enterBasicAuthPassword(String password) async {
    await $(LoginView)
      .$(LoginTextInputBuilder)
      .$(TextField)
      .enterText(password);
  }

  Future<void> loginBasicAuth() async {
    await $(Container).$(ElevatedButton).tap();
  }
}