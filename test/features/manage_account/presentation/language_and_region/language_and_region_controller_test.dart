import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/save_language_to_server_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/language_and_region/language_and_region_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/localizations/localization_service.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

class _MockCachingManager extends Mock implements CachingManager {}
class _MockLanguageCacheManager extends Mock implements LanguageCacheManager {}
class _MockAuthorizationInterceptors extends Mock implements AuthorizationInterceptors {}
class _MockDynamicUrlInterceptors extends Mock implements DynamicUrlInterceptors {}
class _MockDeleteCredentialInteractor extends Mock implements DeleteCredentialInteractor {}
class _MockLogoutOidcInteractor extends Mock implements LogoutOidcInteractor {}
class _MockDeleteAuthorityOidcInteractor extends Mock implements DeleteAuthorityOidcInteractor {}
class _MockAppToast extends Mock implements AppToast {}
class _MockImagePaths extends Mock implements ImagePaths {}
class _MockResponsiveUtils extends Mock implements ResponsiveUtils {}
class _MockUuid extends Mock implements Uuid {}
class _MockToastManager extends Mock implements ToastManager {}
class _MockTwakeAppManager extends Mock implements TwakeAppManager {}
class _MockSaveLanguageInteractor extends Mock implements SaveLanguageInteractor {}
class _MockSaveLanguageToServerSettingsInteractor extends Mock
    implements SaveLanguageToServerSettingsInteractor {}
class _MockManageAccountDashBoardController extends Mock implements ManageAccountDashBoardController {
  @override
  final onStart = InternalFinalCallback<void>(callback: () {});

  @override
  final onDelete = InternalFinalCallback<void>(callback: () {});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late LanguageAndRegionController controller;

  setUp(() {
    Get.testMode = true;
    PlatformInfo.isTestingForWeb = true;
    dotenv.testLoad();
    Get.put<CachingManager>(_MockCachingManager());
    Get.put<LanguageCacheManager>(_MockLanguageCacheManager());
    Get.put<AuthorizationInterceptors>(_MockAuthorizationInterceptors());
    Get.put<AuthorizationInterceptors>(
      _MockAuthorizationInterceptors(),
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(_MockDynamicUrlInterceptors());
    Get.put<DeleteCredentialInteractor>(_MockDeleteCredentialInteractor());
    Get.put<LogoutOidcInteractor>(_MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(_MockDeleteAuthorityOidcInteractor());
    Get.put<AppToast>(_MockAppToast());
    Get.put<ImagePaths>(_MockImagePaths());
    Get.put<ResponsiveUtils>(_MockResponsiveUtils());
    Get.put<Uuid>(_MockUuid());
    Get.put<ToastManager>(_MockToastManager());
    Get.put<TwakeAppManager>(_MockTwakeAppManager());
    Get.put<ManageAccountDashBoardController>(_MockManageAccountDashBoardController());

    controller = LanguageAndRegionController(
      _MockSaveLanguageInteractor(),
      _MockSaveLanguageToServerSettingsInteractor(),
    );
  });

  tearDown(() {
    Get.reset();
    Get.locale = null;
    Get.testMode = false;
    PlatformInfo.isTestingForWeb = false;
  });

  group('LanguageAndRegionController supported languages test:', () {
    test('should list every supported language when ALLOWED_LANGUAGES is not set', () {
      Get.locale = const Locale('fr', 'FR');

      controller.onReady();

      expect(
        controller.listSupportedLanguages,
        LocalizationService.supportedLocales,
      );
      expect(controller.languageSelected.value, const Locale('fr', 'FR'));
    });

    test('should list only the allowed languages in the configured order', () {
      dotenv.testLoad(mergeWith: {'ALLOWED_LANGUAGES': 'mn,en'});
      Get.locale = const Locale('mn', 'MN');

      controller.onReady();

      expect(
        controller.listSupportedLanguages,
        const [Locale('mn', 'MN'), Locale('en', 'US')],
      );
      expect(controller.languageSelected.value, const Locale('mn', 'MN'));
    });

    test('should select the listed entry of the current language', () {
      dotenv.testLoad(mergeWith: {'ALLOWED_LANGUAGES': 'fr,en'});
      Get.locale = const Locale('fr', 'CA');

      controller.onReady();

      expect(controller.languageSelected.value, const Locale('fr', 'FR'));
      expect(Get.locale, const Locale('fr', 'CA'));
    });

    test('should only change the selected entry when ALLOWED_LANGUAGES is not set', () {
      Get.locale = const Locale('en', 'GB');

      controller.onReady();

      expect(controller.languageSelected.value, const Locale('en', 'US'));
      expect(Get.locale, const Locale('en', 'GB'));
    });

    test('should list every supported language when the app does not run on web', () {
      PlatformInfo.isTestingForWeb = false;
      dotenv.testLoad(mergeWith: {'ALLOWED_LANGUAGES': 'mn,en'});
      Get.locale = const Locale('vi', 'VN');

      controller.onReady();

      expect(
        controller.listSupportedLanguages,
        LocalizationService.supportedLocales,
      );
      expect(controller.languageSelected.value, const Locale('vi', 'VN'));
    });

    test('should select the first allowed language when there is no current locale', () {
      dotenv.testLoad(mergeWith: {'ALLOWED_LANGUAGES': 'mn,vi'});
      Get.locale = null;

      controller.onReady();

      expect(controller.languageSelected.value, const Locale('mn', 'MN'));
    });
  });
}
