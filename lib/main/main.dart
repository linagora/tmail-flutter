import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/pages/app_pages.dart';

import 'bindings/main_bindings.dart';
import 'routes/app_routes.dart';

void main() async {
  runApp(TMailApp());
}

class TMailApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      supportedLocales: [
        Locale('en'),
        Locale('vi'),
        Locale('ru'),
        Locale('fr')
      ],
      localizationsDelegates: [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      localeResolutionCallback: (deviceLocale, supportedLocales) {
        for (var locale in supportedLocales) {
          if (locale.languageCode == deviceLocale?.languageCode) {
            return deviceLocale;
          }
        }
        return supportedLocales.first;
      },
      defaultTransition: Transition.fade,
      initialBinding: MainBindings(),
      initialRoute: AppRoutes.SPLASH,
      getPages: AppPages.pages);
  }
}