import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

/// A localized app whose [routeName] page records the arguments it is opened with, for code that
/// navigates with `push`, with SmartDialog ready for loading dialogs. [context] belongs to its home
/// page. GetX keeps the routes and the last route across tests: a page records into the latest
/// recorder, the last route is reset before and after the test, and the instances the test
/// registered are not removed with the routes.
class RouteArgumentsRecorder {
  static RouteArgumentsRecorder? _latest;

  Object? arguments;
  late BuildContext context;

  RouteArgumentsRecorder._();

  static Future<RouteArgumentsRecorder> pump(WidgetTester tester, String routeName) async {
    final recorder = _latest = RouteArgumentsRecorder._();
    Get.routing.current = '';
    addTearDown(() => Get.routing.current = '');
    await tester.pumpWidget(GetMaterialApp(
      smartManagement: SmartManagement.onlyBuilder,
      builder: FlutterSmartDialog.init(),
      locale: LocalizationService.defaultLocale,
      supportedLocales: LocalizationService.supportedLocales,
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      getPages: [
        GetPage(
          name: routeName,
          page: () {
            // A rebuild after the route settles may read no arguments.
            _latest?.arguments ??= Get.arguments;
            return const SizedBox.shrink();
          },
        ),
      ],
      home: Builder(builder: (context) {
        recorder.context = context;
        return const SizedBox.shrink();
      }),
    ));
    await tester.pump();
    return recorder;
  }
}
