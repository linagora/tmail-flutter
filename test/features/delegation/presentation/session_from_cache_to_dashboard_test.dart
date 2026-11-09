import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:mockito/annotations.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_email_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_login_url_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_login_username_interactor.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/home/presentation/home_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/update_authentication_account_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authenticate_oidc_on_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/authentication_user_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/check_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/dns_lookup_to_get_jmap_url_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authentication_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_user_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/remove_auth_destination_url_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/try_guessing_web_finger_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/model/dashboard_session_arguments.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/starting_page/domain/usecase/sign_in_twake_workplace_interactor.dart';
import 'package:tmail_ui_user/features/starting_page/domain/usecase/sign_up_twake_workplace_interactor.dart';
import 'package:tmail_ui_user/features/starting_page/presentation/twake_welcome/twake_welcome_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/routes/app_routes.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import '../../../fixtures/delegation_fixtures.dart';
import '../../../fixtures/route_arguments_recorder.dart';
import 'session_from_cache_to_dashboard_test.mocks.dart';

@GenerateNiceMocks([
  // ReloadableController and BaseController
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<DeleteCredentialInteractor>(),
  MockSpec<LogoutOidcInteractor>(),
  MockSpec<DeleteAuthorityOidcInteractor>(),
  MockSpec<AppToast>(),
  MockSpec<ImagePaths>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
  MockSpec<GetSessionInteractor>(),
  MockSpec<GetAuthenticatedAccountInteractor>(),
  MockSpec<UpdateAccountCacheInteractor>(),
  MockSpec<GetOidcUserInfoInteractor>(),
  // HomeController
  MockSpec<CleanupEmailCacheInteractor>(),
  MockSpec<EmailReceiveManager>(),
  MockSpec<CleanupRecentLoginUrlCacheInteractor>(),
  MockSpec<CleanupRecentLoginUsernameCacheInteractor>(),
  MockSpec<CheckOIDCIsAvailableInteractor>(),
  MockSpec<GetOIDCConfigurationInteractor>(),
  MockSpec<AuthenticateOidcOnBrowserInteractor>(),
  MockSpec<RemoveAuthDestinationUrlInteractor>(),
  // LoginController
  MockSpec<AuthenticationInteractor>(),
  MockSpec<GetTokenOIDCInteractor>(),
  MockSpec<GetAuthenticationInfoInteractor>(),
  MockSpec<GetStoredOidcConfigurationInteractor>(),
  MockSpec<SaveLoginUrlOnMobileInteractor>(),
  MockSpec<GetAllRecentLoginUrlOnMobileInteractor>(),
  MockSpec<SaveLoginUsernameOnMobileInteractor>(),
  MockSpec<GetAllRecentLoginUsernameOnMobileInteractor>(),
  MockSpec<DNSLookupToGetJmapUrlInteractor>(),
  MockSpec<TryGuessingWebFingerInteractor>(),
  // TwakeWelcomeController and LoginController
  MockSpec<SignInTwakeWorkplaceInteractor>(),
  MockSpec<SignUpTwakeWorkplaceInteractor>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  void registerBaseDependencies() {
    Get.put<CachingManager>(MockCachingManager());
    Get.put<LanguageCacheManager>(MockLanguageCacheManager());
    final authorizationInterceptors = MockAuthorizationInterceptors();
    Get.put<AuthorizationInterceptors>(authorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      authorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(MockDynamicUrlInterceptors());
    Get.put<DeleteCredentialInteractor>(MockDeleteCredentialInteractor());
    Get.put<LogoutOidcInteractor>(MockLogoutOidcInteractor());
    Get.put<DeleteAuthorityOidcInteractor>(MockDeleteAuthorityOidcInteractor());
    Get.put<AppToast>(MockAppToast());
    Get.put<ImagePaths>(MockImagePaths());
    Get.put<ResponsiveUtils>(MockResponsiveUtils());
    Get.put<Uuid>(MockUuid());
    Get.put<ToastManager>(MockToastManager());
    Get.put<TwakeAppManager>(MockTwakeAppManager());
    Get.put<GetSessionInteractor>(MockGetSessionInteractor());
    Get.put<GetAuthenticatedAccountInteractor>(
      MockGetAuthenticatedAccountInteractor(),
    );
    Get.put<UpdateAccountCacheInteractor>(MockUpdateAccountCacheInteractor());
    Get.put<GetOidcUserInfoInteractor>(MockGetOidcUserInfoInteractor());
  }

  HomeController buildHome() => HomeController(
        MockCleanupEmailCacheInteractor(),
        MockEmailReceiveManager(),
        MockCleanupRecentLoginUrlCacheInteractor(),
        MockCleanupRecentLoginUsernameCacheInteractor(),
        MockCheckOIDCIsAvailableInteractor(),
        MockGetOIDCConfigurationInteractor(),
        MockAuthenticateOidcOnBrowserInteractor(),
        MockRemoveAuthDestinationUrlInteractor(),
      );

  LoginController buildLogin() => LoginController(
        MockAuthenticationInteractor(),
        MockCheckOIDCIsAvailableInteractor(),
        MockGetOIDCConfigurationInteractor(),
        MockGetTokenOIDCInteractor(),
        MockAuthenticateOidcOnBrowserInteractor(),
        MockGetAuthenticationInfoInteractor(),
        MockGetStoredOidcConfigurationInteractor(),
        MockSaveLoginUrlOnMobileInteractor(),
        MockGetAllRecentLoginUrlOnMobileInteractor(),
        MockSaveLoginUsernameOnMobileInteractor(),
        MockGetAllRecentLoginUsernameOnMobileInteractor(),
        MockDNSLookupToGetJmapUrlInteractor(),
        MockSignInTwakeWorkplaceInteractor(),
        MockTryGuessingWebFingerInteractor(),
        MockRemoveAuthDestinationUrlInteractor(),
      );

  TwakeWelcomeController buildWelcome() => TwakeWelcomeController(
        MockSignInTwakeWorkplaceInteractor(),
        MockSignUpTwakeWorkplaceInteractor(),
      );

  final screens = <String, ReloadableController Function()>{
    'HomeController': buildHome,
    'LoginController': buildLogin,
    'TwakeWelcomeController': buildWelcome,
  };

  setUp(() {
    Get.testMode = true;
    dotenv.testLoad(mergeWith: {'SERVER_URL': 'https://example.com'});
    registerBaseDependencies();
  });

  tearDown(Get.reset);

  /// Runs the real session-read chain of [ReloadableController]:
  /// GetSessionSuccess, then UpdateAccountCacheSuccess, then handleReloaded.
  Future<DashboardSessionArguments> openDashboardAfterSessionRead(
    WidgetTester tester,
    ReloadableController controller,
    Session session, {
    required bool fromCache,
  }) async {
    final recorder = await RouteArgumentsRecorder.pump(
      tester,
      AppRoutes.dashboard,
    );

    controller.handleSuccessViewState(
      GetSessionSuccess(session, fromCache: fromCache),
    );
    controller.handleSuccessViewState(
      UpdateAccountCacheSuccess(session: session, apiUrl: 'https://example.com/jmap'),
    );
    await tester.pumpAndSettle();

    final arguments = recorder.arguments;
    expect(arguments, isA<DashboardSessionArguments>());
    return arguments as DashboardSessionArguments;
  }

  for (final entry in screens.entries) {
    group('${entry.key} hands the session origin to the dashboard', () {
      testWidgets(
        'WHEN the session was read from cache\n'
        'THEN the dashboard receives fromCache true, so ended delegations are not cleaned up',
        (tester) async {
          final session = DelegationFixtures.session();

          final arguments = await openDashboardAfterSessionRead(
            tester,
            entry.value(),
            session,
            fromCache: true,
          );

          expect(arguments.fromCache, isTrue);
          expect(arguments.session, session);
        },
      );

      testWidgets(
        'WHEN the session was read online\n'
        'THEN the dashboard receives fromCache false, so ended delegations are cleaned up',
        (tester) async {
          final session = DelegationFixtures.session();

          final arguments = await openDashboardAfterSessionRead(
            tester,
            entry.value(),
            session,
            fromCache: false,
          );

          expect(arguments.fromCache, isFalse);
          expect(arguments.session, session);
        },
      );

      testWidgets(
        'WHEN an online read follows a cached read on the same screen\n'
        'THEN the dashboard receives fromCache false from the latest read',
        (tester) async {
          final session = DelegationFixtures.session();
          final controller = entry.value();
          controller.handleSuccessViewState(
            GetSessionSuccess(session, fromCache: true),
          );

          final arguments = await openDashboardAfterSessionRead(
            tester,
            controller,
            session,
            fromCache: false,
          );

          expect(arguments.fromCache, isFalse);
        },
      );
    });
  }
}
