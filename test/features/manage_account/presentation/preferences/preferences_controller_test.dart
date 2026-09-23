import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/sentry/sentry_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:server_settings/server_settings/tmail_server_settings.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_user_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_local_settings_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/manage_account_dashboard_controller.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/model/preference_option_registry.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/preferences/preferences_controller.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/get_server_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/state/update_server_setting_state.dart';
import 'package:tmail_ui_user/features/server_settings/domain/usecases/get_server_setting_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
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
class _MockGetSessionInteractor extends Mock implements GetSessionInteractor {}
class _MockGetAuthenticatedAccountInteractor extends Mock implements GetAuthenticatedAccountInteractor {}
class _MockUpdateAccountCacheInteractor extends Mock implements UpdateAccountCacheInteractor {}
class _MockGetOidcUserInfoInteractor extends Mock implements GetOidcUserInfoInteractor {}
class _MockManageAccountDashBoardController extends Mock implements ManageAccountDashBoardController {
  @override
  final onStart = InternalFinalCallback<void>(callback: () {});

  @override
  final onDelete = InternalFinalCallback<void>(callback: () {});
}
class _MockGetServerSettingInteractor extends Mock implements GetServerSettingInteractor {}
class _MockGetLocalSettingsInteractor extends Mock implements GetLocalSettingsInteractor {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final sentryManager = SentryManager.instance;
  late PreferencesController controller;

  setUp(() {
    Get.testMode = true;
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
    Get.put<GetSessionInteractor>(_MockGetSessionInteractor());
    Get.put<GetAuthenticatedAccountInteractor>(_MockGetAuthenticatedAccountInteractor());
    Get.put<UpdateAccountCacheInteractor>(_MockUpdateAccountCacheInteractor());
    Get.put<GetOidcUserInfoInteractor>(_MockGetOidcUserInfoInteractor());
    Get.put<ManageAccountDashBoardController>(
      _MockManageAccountDashBoardController(),
    );

    controller = PreferencesController(
      _MockGetServerSettingInteractor(),
      _MockGetLocalSettingsInteractor(),
      PreferenceOptionRegistry([]),
    );
    sentryManager
      ..setSentryReportingDefault(false)
      ..setSentryReportingConsent(false);
  });

  tearDown(() {
    sentryManager
      ..setSentryReportingConsent(null)
      ..setSentryReportingDefault(true);
    Get.deleteAll();
  });

  test('applies consent returned by a successful server settings fetch', () {
    controller.onData(Right(GetServerSettingSuccess(
      TMailServerSettingOptions(sentryUserOptIn: true),
    )));

    expect(sentryManager.isSentryReportingAllowed, isTrue);
    expect(controller.settingOption.value?.sentryUserOptIn, isTrue);
  });

  test('applies an update only after the server acknowledges it', () {
    controller.onData(Right(UpdatingServerSetting()));

    expect(sentryManager.isSentryReportingAllowed, isFalse);

    controller.onData(Right(UpdateServerSettingSuccess(
      TMailServerSettingOptions(sentryUserOptIn: true),
    )));

    expect(sentryManager.isSentryReportingAllowed, isTrue);
  });

  test('fetch and update failures preserve the consent already in effect', () {
    sentryManager.setSentryReportingConsent(true);

    controller.onData(Left(GetServerSettingFailure(StateError('fetch failed'))));
    expect(sentryManager.isSentryReportingAllowed, isTrue);

    controller.onData(Left(UpdateServerSettingFailure(StateError('update failed'))));
    expect(sentryManager.isSentryReportingAllowed, isTrue);
  });
}
