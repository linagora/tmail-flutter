import 'package:core/presentation/utils/theme_utils.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/build_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:get/get.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/main/bindings/main_bindings.dart';
import 'package:tmail_ui_user/main/deep_links/deep_links_manager.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations.dart';
import 'package:tmail_ui_user/main/localizations/app_localizations_delegate.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/pages/app_pages.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/routes/route_navigation.dart';
import 'package:tmail_ui_user/main/utils/app_utils.dart';
import 'package:url_strategy/url_strategy.dart';
import 'package:worker_manager/worker_manager.dart';

Future<void> main() async {
  initLogger(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await runTmail();
  });
}

Future<void> runTmail() async {
  ThemeUtils.setSystemLightUIStyle();
  
  await Future.wait([
     MainBindings().dependencies(),
     HiveCacheConfig.instance.setUp(),
     Executor().warmUp(log: BuildUtils.isDebugMode),
     AppUtils.loadEnvFile()
  ]);
  await HiveCacheConfig.instance.initializeEncryptionKey();
  
  setPathUrlStrategy();
  
  runApp(const TMailApp());
}

class TMailApp extends StatefulWidget {
  const TMailApp({Key? key}) : super(key: key);

  @override
  State<TMailApp> createState() => _TMailAppState();
}

class _TMailAppState extends State<TMailApp> {

  DeepLinksManager? _deepLinksManager;

  @override
  void initState() {
    super.initState();
    if (PlatformInfo.isMobile) {
      _deepLinksManager = getBinding<DeepLinksManager>();
      _deepLinksManager?.registerDeepLinkStreamListener();
    }
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeUtils.appTheme,
      supportedLocales: LocalizationService.supportedLocales,
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
      locale: LocalizationService.getLocaleFromLanguage(),
      fallbackLocale: LocalizationService.fallbackLocale,
      translations: LocalizationService(),
      onGenerateTitle: (context) {
        if (Get.currentRoute == AppRoutes.unknownRoutePage) {
          return AppLocalizations.of(context).page404;
        } else {
          return AppLocalizations.of(context).page_name;
        }
      },
      unknownRoute: AppPages.unknownRoutePage,
      defaultTransition: Transition.noTransition,
      initialRoute: AppRoutes.home,
      getPages: AppPages.pages,
      builder: FlutterSmartDialog.init(),
    );
  }

  @override
  void dispose() {
    if (PlatformInfo.isMobile) {
      _deepLinksManager?.dispose();
    }
    super.dispose();
  }
}