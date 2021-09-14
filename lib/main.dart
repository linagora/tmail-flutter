import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/pages/app_pages.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MainBindings().dependencies();
  // Disable landscape on device mobile
  if (Get.size.shortestSide < ResponsiveUtils.minTabletWidth) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
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
      initialRoute: AppRoutes.HOME,
      getPages: AppPages.pages);
  }
}