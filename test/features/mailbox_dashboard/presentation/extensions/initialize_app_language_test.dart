import 'package:flutter/widgets.dart';
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
    Get.locale = const Locale('fr', 'FR');
    Get.put<LanguageCacheManager>(languageCacheManager);
  });

  tearDown(() {
    Get.reset();
    Get.locale = null;
    Get.testMode = false;
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
}