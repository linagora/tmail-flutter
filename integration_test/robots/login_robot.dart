import 'package:flutter/material.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/login/presentation/login_view.dart';

import '../base/core_robot.dart';

class LoginRobot extends CoreRobot {
  LoginRobot(super.$);

  Future<void> expectLoginViewVisible() => ensureViewVisible($(LoginView));

  Future<void> enterEmail(String email) async {
    final finder = $(LoginView).$(TextField);
    await finder.enterText(email);
    await $('Next').tap();
  }

  Future<void> enterHostUrl(String url) async {
    final finder = $(LoginView).$(TextField);
    await finder.enterText(url);
    await $('Next').tap();
    await $.pumpAndTrySettle(duration: const Duration(seconds: 10));
  }

  Future<void> enterOidcUsername(String username) async {
    await $.native.enterTextByIndex(username, index: 0);
  }

  Future<void> enterOidcPassword(String password) async {
    await $.native.enterTextByIndex(password, index: 1);
  }

  Future<void> loginOidc() async {
    await $.native.tap(Selector(text: 'Sign In'));
  }
}