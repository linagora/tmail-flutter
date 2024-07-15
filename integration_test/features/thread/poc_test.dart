import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:tmail_ui_user/features/login/presentation/login_view.dart';
import 'package:tmail_ui_user/features/thread/presentation/thread_view.dart';
import 'package:tmail_ui_user/main.dart' as app;

void main() {
  patrolTest('login and show thread view',
      config: const PatrolTesterConfig(settlePolicy: SettlePolicy.trySettle),
      ($) async {
    app.runTmail();
    // https://github.com/leancodepl/patrol/issues/1602#issuecomment-1665317814
    final originalOnError = FlutterError.onError!;
    FlutterError.onError = (FlutterErrorDetails details) {
      originalOnError(details);
    };

    await $.waitUntilVisible($(LoginView),
        timeout: const Duration(seconds: 10));
    expect($(LoginView), findsOneWidget);

    final finder = $(LoginView).$(TextField);
    await finder.enterText('first');

    await $('Next').tap();

    await Future.delayed(const Duration(seconds: 2));

    final finderHttps = $(LoginView).$(TextField);
    await finderHttps.enterText('apisix.upn.integration-open-paas.org');
    await $('Next').tap();

    await $.native.enterTextByIndex(
      'firstname100.surname100@upn.integration-open-paas.org',
      index: 0
    );
    await $.native.enterTextByIndex('XXXXXXXX', index: 1);

    await $.native.tap(Selector(text: 'Sign In'));

    await $.waitUntilVisible($(ThreadView),
        timeout: const Duration(seconds: 10));

    expect($(ThreadView), findsOneWidget);
  });
}
