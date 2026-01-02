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

  /// Sets up responsive testing with the specified [logicalSize] and optional [platform].
  ///
  /// Note: This method modifies global state via [debugDefaultTargetPlatformOverride].
  /// Always call [resetResponsive] in your test's tearDown to clean up:
  ///
  /// ```dart
  /// tearDown(() {
  ///   WidgetFixtures.resetResponsive(tester);
  /// });
  /// ```
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

  /// Pumps a widget with responsive setup for the specified [logicalSize] and optional [platform].
  ///
  /// Note: This method does not wrap the widget with [makeTestableWidget].
  /// If your widget requires localization or GetX context, wrap it first:
  ///
  /// ```dart
  /// await WidgetFixtures.pumpResponsiveWidget(
  ///   tester,
  ///   WidgetFixtures.makeTestableWidget(child: YourWidget()),
  ///   logicalSize: Size(800, 600),
  /// );
  /// ```
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
