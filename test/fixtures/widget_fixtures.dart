import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

class WidgetFixtures {
  static Widget makeTestableWidget({required Widget child}) {
    return GetMaterialApp(
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: LocalizationService.supportedLocales,
      locale: LocalizationService.defaultLocale,
      home: Scaffold(body: child),
    );
  }

  static Future<void> setupResponsive(
    WidgetTester tester, {
    required Size logicalSize,
    TargetPlatform? platform,
  }) async {
    if (platform != null) {
      debugDefaultTargetPlatformOverride = platform;
    }

    final dpi = tester.view.devicePixelRatio;
    tester.view.physicalSize =
        Size(logicalSize.width * dpi, logicalSize.height * dpi);

    await tester.pump();
  }

  static void resetResponsive(WidgetTester tester) {
    debugDefaultTargetPlatformOverride = null;
    tester.view.reset();
  }

  static Future<void> pumpResponsiveWidget(
    WidgetTester tester,
    Widget widget, {
    required Size logicalSize,
    TargetPlatform? platform,
  }) async {
    await tester.pumpWidget(widget);

    await WidgetFixtures.setupResponsive(
      tester,
      logicalSize: logicalSize,
      platform: platform,
    );

    await tester.pump();
  }
}
