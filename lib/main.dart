import 'package:core/core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/pages/app_pages.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';

void main() async {
  initLogger(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await MainBindings().dependencies();
    await HiveCacheConfig().setUp();
    await dotenv.load(fileName: 'env.file');
    runApp(const TMailApp());
  });
}

class TMailApp extends StatelessWidget {
  const TMailApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      supportedLocales: const [
        Locale('en'),
        Locale('vi'),
        Locale('ru'),
        Locale('fr')
      ],
      localizationsDelegates: const [
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
      locale: Get.locale ?? const Locale('en'),
      onGenerateTitle: (context) => AppLocalizations.of(context).page_name,
      defaultTransition: Transition.fade,
      initialRoute: AppRoutes.HOME,
      getPages: AppPages.pages);
  }
}