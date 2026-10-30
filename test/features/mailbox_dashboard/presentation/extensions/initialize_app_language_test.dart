import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/extensions/initialize_app_language.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_server_setting_state.dart';
import 'package:tmail_ui_user/main/localizations/language_code_constants.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';

import 'initialize_app_language_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<MailboxDashBoardController>(),
  MockSpec<LanguageCacheManager>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final mailboxDashboardController = MockMailboxDashBoardController();
  final languageCacheManager = MockLanguageCacheManager();

  setUp(() {
    Get.testMode = true;
    dotenv.testLoad();
    Get.locale = const Locale('fr', 'FR');
    Get.put<LanguageCacheManager>(languageCacheManager);
  });

  tearDown(() {
    Get.reset();
    Get.locale = null;
    Get.testMode = false;
    TestWidgetsFlutterBinding.instance.platformDispatcher.clearLocaleTestValue();
    TestWidgetsFlutterBinding.instance.reset();
  });

  group('initialize app language test:', () {
    testWidgets(
      'should apply server language '
      'when server language is not null '
      'and server language is supported',
    (tester) async {
      // arrange
      final success = GetServerSettingSuccess(TMailServerSettingOptions(
        language: LanguageCodeConstants.vietnamese,
      ));
      
      // act
      mailboxDashboardController.initializeAppLanguage(success);
      await tester.pumpAndSettle();
      
      // assert
      expect(Get.locale?.languageCode, LanguageCodeConstants.vietnamese);
    });

    testWidgets(
      'should apply cached language '
      'when server language is null '
      'and cached language is not null '
      'and cached language is supported',
    (tester) async {
      // arrange
      const expectedLocale = Locale('en', 'US');
      final success = GetServerSettingSuccess(TMailServerSettingOptions(
        language: null,
      ));
      when(languageCacheManager.getStoredLanguage()).thenReturn(expectedLocale);
      
      // act
      mailboxDashboardController.initializeAppLanguage(success);
      await tester.pumpAndSettle();
      
      // assert
      expect(Get.locale, expectedLocale);
    });

    testWidgets(
      'should apply cached language '
      'when server language is not null '
      'and server language is not supported '
      'and cached language is not null '
      'and cached language is supported',
    (tester) async {
      // arrange
      const expectedLocale = Locale('en', 'US');
      final success = GetServerSettingSuccess(TMailServerSettingOptions(
        language: 'fi',
      ));
      when(languageCacheManager.getStoredLanguage()).thenReturn(expectedLocale);
      
      // act
      mailboxDashboardController.initializeAppLanguage(success);
      await tester.pumpAndSettle();
      
      // assert
      expect(Get.locale, expectedLocale);
    });

    testWidgets(
      'should apply device language '
      'when server language is null '
      'and cached language is null '
      'and device language is supported',
    (tester) async {
      // arrange
      const expectedLocale = Locale('en', 'US');
      final success = GetServerSettingSuccess(TMailServerSettingOptions(
        language: null,
      ));
      when(languageCacheManager.getStoredLanguage()).thenReturn(null);
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = expectedLocale;
      
      // act
      mailboxDashboardController.initializeAppLanguage(success);
      await tester.pumpAndSettle();
      
      // assert
      expect(Get.locale, expectedLocale);
    });

    testWidgets(
      'should apply device language '
      'when server language is not null '
      'and server language is not supported '
      'and cached language is null '
      'and device language is supported',
    (tester) async {
      // arrange
      const expectedLocale = Locale('en', 'US');
      final success = GetServerSettingSuccess(TMailServerSettingOptions(
        language: 'fi',
      ));
      when(languageCacheManager.getStoredLanguage()).thenReturn(null);
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = expectedLocale;
      
      // act
      mailboxDashboardController.initializeAppLanguage(success);
      await tester.pumpAndSettle();
      
      // assert
      expect(Get.locale, expectedLocale);
    });

    testWidgets(
      'should apply device language '
      'when server language is null '
      'and cached language is not null '
      'and cached language is not supported '
      'and device language is supported',
    (tester) async {
      // arrange
      const expectedLocale = Locale('en', 'US');
      final success = GetServerSettingSuccess(TMailServerSettingOptions(
        language: null,
      ));
      when(languageCacheManager.getStoredLanguage())
        .thenReturn(const Locale('fi', 'FI'));
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = expectedLocale;
      
      // act
      mailboxDashboardController.initializeAppLanguage(success);
      await tester.pumpAndSettle();
      
      // assert
      expect(Get.locale, expectedLocale);
    });

    testWidgets(
      'should apply device language '
      'when server language is not null '
      'and server language is not supported '
      'and cached language is not null '
      'and cached language is not supported '
      'and device language is supported',
    (tester) async {
      // arrange
      const expectedLocale = Locale('en', 'US');
      final success = GetServerSettingSuccess(TMailServerSettingOptions(
        language: 'es',
      ));
      when(languageCacheManager.getStoredLanguage())
        .thenReturn(const Locale('fi', 'FI'));
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = expectedLocale;
      
      // act
      mailboxDashboardController.initializeAppLanguage(success);
      await tester.pumpAndSettle();
      
      // assert
      expect(Get.locale, expectedLocale);
    });

    testWidgets(
      'should apply default language (English) '
      'when server language is null '
      'and cached language is null '
      'and current locale is null '
      'and device language is not supported',
    (tester) async {
      // arrange
      final success = GetServerSettingSuccess(TMailServerSettingOptions(
        language: null,
      ));
      when(languageCacheManager.getStoredLanguage()).thenReturn(null);
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = const Locale('es', 'ES');
      Get.locale = null;
      
      // act
      mailboxDashboardController.initializeAppLanguage(success);
      await tester.pumpAndSettle();
      
      // assert
      expect(Get.locale, LocalizationService.defaultLocale);
    });

    testWidgets(
      'should apply default language (English) '
      'when server language is not null '
      'and server language is not supported '
      'and cached language is null '
      'and current locale is null '
      'and device language is not supported',
    (tester) async {
      // arrange
      final success = GetServerSettingSuccess(TMailServerSettingOptions(
        language: 'fi',
      ));
      when(languageCacheManager.getStoredLanguage()).thenReturn(null);
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = const Locale('es', 'ES');
      Get.locale = null;
      
      // act
      mailboxDashboardController.initializeAppLanguage(success);
      await tester.pumpAndSettle();
      
      // assert
      expect(Get.locale, LocalizationService.defaultLocale);
    });

    testWidgets(
      'should apply default language (English) '
      'when server language is null '
      'and cached language is not null '
      'and cached language is not supported '
      'and current locale is null '
      'and device language is not supported',
    (tester) async {
      // arrange
      final success = GetServerSettingSuccess(TMailServerSettingOptions(
        language: null,
      ));
      when(languageCacheManager.getStoredLanguage())
        .thenReturn(const Locale('fi', 'FI'));
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = const Locale('es', 'ES');
      Get.locale = null;
      
      // act
      mailboxDashboardController.initializeAppLanguage(success);
      await tester.pumpAndSettle();
      
      // assert
      expect(Get.locale, LocalizationService.defaultLocale);
    });

    testWidgets(
      'should apply default language (English) '
      'when server language is null '
      'and cached language is null '
      'and current locale is not null '
      'and current locale is not supported '
      'and device language is not supported',
    (tester) async {
      // arrange
      final success = GetServerSettingSuccess(TMailServerSettingOptions(
        language: null,
      ));
      when(languageCacheManager.getStoredLanguage()).thenReturn(null);
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = const Locale('es', 'ES');
      Get.locale = const Locale('fi', 'FI');
      
      // act
      mailboxDashboardController.initializeAppLanguage(success);
      await tester.pumpAndSettle();
      
      // assert
      expect(Get.locale, LocalizationService.defaultLocale);
    });
  });

  group('initialize app language with ALLOWED_LANGUAGES test:', () {
    void allowLanguages(String value) =>
        dotenv.testLoad(mergeWith: {'ALLOWED_LANGUAGES': value});

    setUp(() => PlatformInfo.isTestingForWeb = true);

    tearDown(() => PlatformInfo.isTestingForWeb = false);

    testWidgets(
      'should apply a language that is not allowed '
      'when the app does not run on web',
    (tester) async {
      // arrange
      PlatformInfo.isTestingForWeb = false;
      allowLanguages('mn,en');
      Locale? appliedServerLocale;

      // act
      LocalizationService.initializeAppLanguage(
        serverLanguage: LanguageCodeConstants.vietnamese,
        onServerLanguageApplied: (locale) => appliedServerLocale = locale,
      );
      await tester.pumpAndSettle();

      // assert
      expect(appliedServerLocale, const Locale('vi', 'VN'));
      expect(Get.locale, const Locale('vi', 'VN'));
    });

    testWidgets(
      'should not apply nor persist server language '
      'when server language is not allowed',
    (tester) async {
      // arrange
      allowLanguages('mn,en');
      when(languageCacheManager.getStoredLanguage()).thenReturn(null);
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = const Locale('mn', 'MN');
      Locale? appliedServerLocale;

      // act
      LocalizationService.initializeAppLanguage(
        serverLanguage: LanguageCodeConstants.vietnamese,
        onServerLanguageApplied: (locale) => appliedServerLocale = locale,
      );
      await tester.pumpAndSettle();

      // assert
      expect(appliedServerLocale, isNull);
      expect(Get.locale, const Locale('mn', 'MN'));
    });

    testWidgets(
      'should apply server language '
      'when server language is allowed',
    (tester) async {
      // arrange
      allowLanguages('mn,en');
      Locale? appliedServerLocale;

      // act
      LocalizationService.initializeAppLanguage(
        serverLanguage: LanguageCodeConstants.mongolian,
        onServerLanguageApplied: (locale) => appliedServerLocale = locale,
      );
      await tester.pumpAndSettle();

      // assert
      expect(appliedServerLocale, const Locale('mn', 'MN'));
      expect(Get.locale, const Locale('mn', 'MN'));
    });

    testWidgets(
      'should apply English '
      'when server, cached, device and current languages are not allowed '
      'and English is allowed',
    (tester) async {
      // arrange
      allowLanguages('mn,en');
      when(languageCacheManager.getStoredLanguage())
        .thenReturn(const Locale('vi', 'VN'));
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = const Locale('fr', 'FR');

      // act
      LocalizationService.initializeAppLanguage(
        serverLanguage: LanguageCodeConstants.russian,
      );
      await tester.pumpAndSettle();

      // assert
      expect(Get.locale, LocalizationService.defaultLocale);
    });

    testWidgets(
      'should apply the first allowed language '
      'when server, cached, device and current languages are not allowed '
      'and English is not allowed',
    (tester) async {
      // arrange
      allowLanguages('mn,vi');
      when(languageCacheManager.getStoredLanguage())
        .thenReturn(const Locale('de', 'DE'));
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = const Locale('fr', 'FR');

      // act
      LocalizationService.initializeAppLanguage();
      await tester.pumpAndSettle();

      // assert
      expect(Get.locale, const Locale('mn', 'MN'));
    });

    testWidgets(
      'should keep the device region '
      'when device language is allowed',
    (tester) async {
      // arrange
      allowLanguages('fr,en');
      when(languageCacheManager.getStoredLanguage()).thenReturn(null);
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = const Locale('fr', 'CA');

      // act
      LocalizationService.initializeAppLanguage();
      await tester.pumpAndSettle();

      // assert
      expect(Get.locale, const Locale('fr', 'CA'));
    });

    testWidgets(
      'should keep the device region '
      'when ALLOWED_LANGUAGES is not set',
    (tester) async {
      // arrange
      when(languageCacheManager.getStoredLanguage()).thenReturn(null);
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = const Locale('en', 'GB');

      // act
      LocalizationService.initializeAppLanguage();
      await tester.pumpAndSettle();

      // assert
      expect(Get.locale, const Locale('en', 'GB'));
    });

    testWidgets(
      'getInitialLocale should skip a cached language '
      'that is not allowed',
    (tester) async {
      // arrange
      allowLanguages('mn,en');
      when(languageCacheManager.getStoredLanguage())
        .thenReturn(const Locale('vi', 'VN'));
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = const Locale('fr', 'FR');

      // act
      final initialLocale = LocalizationService.getInitialLocale();

      // assert
      expect(initialLocale, LocalizationService.defaultLocale);
    });

    testWidgets(
      'getInitialLocale should return the first allowed language '
      'when cached and device languages are not allowed '
      'and English is not allowed',
    (tester) async {
      // arrange
      allowLanguages('mn,fr');
      when(languageCacheManager.getStoredLanguage())
        .thenReturn(const Locale('vi', 'VN'));
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = const Locale('en', 'US');

      // act
      final initialLocale = LocalizationService.getInitialLocale();

      // assert
      expect(initialLocale, const Locale('mn', 'MN'));
    });

    testWidgets(
      'should keep the current language '
      'when server, cached and device languages are not allowed '
      'and the current language is allowed',
    (tester) async {
      // arrange
      allowLanguages('mn,fr');
      Get.locale = const Locale('fr', 'FR');
      when(languageCacheManager.getStoredLanguage())
        .thenReturn(const Locale('vi', 'VN'));
      TestWidgetsFlutterBinding
        .instance
        .platformDispatcher
        .localeTestValue = const Locale('de', 'DE');

      // act
      LocalizationService.initializeAppLanguage(
        serverLanguage: LanguageCodeConstants.russian,
      );
      await tester.pumpAndSettle();

      // assert
      expect(Get.locale, const Locale('fr', 'FR'));
    });
  });
}
