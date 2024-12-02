
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/login_exception.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_token_oidc_state.dart';
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
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_is_available_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_stored_oidc_configuration_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/starting_page/domain/usecase/sign_in_twake_workplace_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'login_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<DeleteCredentialInteractor>(),
  MockSpec<LogoutOidcInteractor>(),
  MockSpec<DeleteAuthorityOidcInteractor>(),
  MockSpec<AppToast>(),
  MockSpec<ImagePaths>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<AuthenticationInteractor>(),
  MockSpec<CheckOIDCIsAvailableInteractor>(),
  MockSpec<GetOIDCIsAvailableInteractor>(),
  MockSpec<GetOIDCConfigurationInteractor>(),
  MockSpec<GetTokenOIDCInteractor>(),
  MockSpec<AuthenticateOidcOnBrowserInteractor>(),
  MockSpec<GetAuthenticationInfoInteractor>(),
  MockSpec<GetStoredOidcConfigurationInteractor>(),
  MockSpec<SaveLoginUrlOnMobileInteractor>(),
  MockSpec<GetAllRecentLoginUrlOnMobileInteractor>(),
  MockSpec<SaveLoginUsernameOnMobileInteractor>(),
  MockSpec<GetAllRecentLoginUsernameOnMobileInteractor>(),
  MockSpec<DNSLookupToGetJmapUrlInteractor>(),
  MockSpec<SignInTwakeWorkplaceInteractor>(),
  MockSpec<GetSessionInteractor>(),
  MockSpec<GetAuthenticatedAccountInteractor>(),
  MockSpec<UpdateAccountCacheInteractor>(),
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<ApplicationManager>(),
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
])
void main() {
  late MockAuthenticationInteractor mockAuthenticationInteractor;
  late MockCheckOIDCIsAvailableInteractor mockCheckOIDCIsAvailableInteractor;
  late MockGetOIDCIsAvailableInteractor mockGetOIDCIsAvailableInteractor;
  late MockGetOIDCConfigurationInteractor mockGetOIDCConfigurationInteractor;
  late MockGetTokenOIDCInteractor mockGetTokenOIDCInteractor;
  late MockAuthenticateOidcOnBrowserInteractor mockAuthenticateOidcOnBrowserInteractor;
  late MockGetAuthenticationInfoInteractor mockGetAuthenticationInfoInteractor;
  late MockGetStoredOidcConfigurationInteractor mockGetStoredOidcConfigurationInteractor;
  late MockSaveLoginUrlOnMobileInteractor mockSaveLoginUrlOnMobileInteractor;
  late MockGetAllRecentLoginUrlOnMobileInteractor mockGetAllRecentLoginUrlOnMobileInteractor;
  late MockSaveLoginUsernameOnMobileInteractor mockSaveLoginUsernameOnMobileInteractor;
  late MockGetAllRecentLoginUsernameOnMobileInteractor mockGetAllRecentLoginUsernameOnMobileInteractor;
  late MockDNSLookupToGetJmapUrlInteractor mockDNSLookupToGetJmapUrlInteractor;
  late MockSignInTwakeWorkplaceInteractor mockSignInTwakeWorkplaceInteractor;
  late MockGetSessionInteractor mockGetSessionInteractor;
  late MockGetAuthenticatedAccountInteractor mockGetAuthenticatedAccountInteractor;
  late MockUpdateAccountCacheInteractor mockUpdateAccountCacheInteractor;
  late CachingManager mockCachingManager;
  late LanguageCacheManager mockLanguageCacheManager;
  late MockAuthorizationInterceptors mockAuthorizationInterceptors;
  late MockDynamicUrlInterceptors mockDynamicUrlInterceptors;
  late MockDeleteCredentialInteractor mockDeleteCredentialInteractor;
  late MockLogoutOidcInteractor mockLogoutOidcInteractor;
  late MockDeleteAuthorityOidcInteractor mockDeleteAuthorityOidcInteractor;
  late MockAppToast mockAppToast;
  late MockImagePaths mockImagePaths;
  late MockResponsiveUtils mockResponsiveUtils;
  late MockUuid mockUuid;
  late MockApplicationManager mockApplicationManager;
  late MockToastManager mockToastManager;
  late MockTwakeAppManager mockTwakeAppManager;

  late LoginController loginController;

  group('Test handleFailureViewState with GetTokenOIDCFailure', () {
    setUp(() {
      mockAuthenticationInteractor = MockAuthenticationInteractor();
      mockCheckOIDCIsAvailableInteractor = MockCheckOIDCIsAvailableInteractor();
      mockGetOIDCIsAvailableInteractor = MockGetOIDCIsAvailableInteractor();
      mockGetOIDCConfigurationInteractor = MockGetOIDCConfigurationInteractor();
      mockGetTokenOIDCInteractor = MockGetTokenOIDCInteractor();
      mockAuthenticateOidcOnBrowserInteractor = MockAuthenticateOidcOnBrowserInteractor();
      mockGetAuthenticationInfoInteractor = MockGetAuthenticationInfoInteractor();
      mockGetStoredOidcConfigurationInteractor = MockGetStoredOidcConfigurationInteractor();
      mockSaveLoginUrlOnMobileInteractor = MockSaveLoginUrlOnMobileInteractor();
      mockGetAllRecentLoginUrlOnMobileInteractor = MockGetAllRecentLoginUrlOnMobileInteractor();
      mockSaveLoginUsernameOnMobileInteractor = MockSaveLoginUsernameOnMobileInteractor();
      mockGetAllRecentLoginUsernameOnMobileInteractor = MockGetAllRecentLoginUsernameOnMobileInteractor();
      mockDNSLookupToGetJmapUrlInteractor = MockDNSLookupToGetJmapUrlInteractor();
      mockSignInTwakeWorkplaceInteractor = MockSignInTwakeWorkplaceInteractor();

      // mock reloadable controller
      mockGetSessionInteractor = MockGetSessionInteractor();
      mockGetAuthenticatedAccountInteractor = MockGetAuthenticatedAccountInteractor();
      mockUpdateAccountCacheInteractor = MockUpdateAccountCacheInteractor();

      //mock base controller
      mockCachingManager = MockCachingManager();
      mockLanguageCacheManager = MockLanguageCacheManager();
      mockAuthorizationInterceptors = MockAuthorizationInterceptors();
      mockDynamicUrlInterceptors = MockDynamicUrlInterceptors();
      mockDeleteCredentialInteractor = MockDeleteCredentialInteractor();
      mockLogoutOidcInteractor = MockLogoutOidcInteractor();
      mockDeleteAuthorityOidcInteractor = MockDeleteAuthorityOidcInteractor();
      mockAppToast = MockAppToast();
      mockImagePaths = MockImagePaths();
      mockResponsiveUtils = MockResponsiveUtils();
      mockUuid = MockUuid();
      mockApplicationManager = MockApplicationManager();
      mockToastManager = MockToastManager();
      mockTwakeAppManager = MockTwakeAppManager();

      Get.put<GetSessionInteractor>(mockGetSessionInteractor);
      Get.put<GetAuthenticatedAccountInteractor>(mockGetAuthenticatedAccountInteractor);
      Get.put<UpdateAccountCacheInteractor>(mockUpdateAccountCacheInteractor);
      Get.put<CachingManager>(mockCachingManager);
      Get.put<LanguageCacheManager>(mockLanguageCacheManager);
      Get.put<AuthorizationInterceptors>(mockAuthorizationInterceptors);
      Get.put<AuthorizationInterceptors>(
        mockAuthorizationInterceptors,
        tag: BindingTag.isolateTag,
      );
      Get.put<DynamicUrlInterceptors>(mockDynamicUrlInterceptors);
      Get.put<DeleteCredentialInteractor>(mockDeleteCredentialInteractor);
      Get.put<LogoutOidcInteractor>(mockLogoutOidcInteractor);
      Get.put<DeleteAuthorityOidcInteractor>(mockDeleteAuthorityOidcInteractor);
      Get.put<AppToast>(mockAppToast);
      Get.put<ImagePaths>(mockImagePaths);
      Get.put<ResponsiveUtils>(mockResponsiveUtils);
      Get.put<Uuid>(mockUuid);
      Get.put<ApplicationManager>(mockApplicationManager);
      Get.put<ToastManager>(mockToastManager);
      Get.put<TwakeAppManager>(mockTwakeAppManager);
      Get.testMode = true;

      loginController = LoginController(
        mockAuthenticationInteractor,
        mockCheckOIDCIsAvailableInteractor,
        mockGetOIDCIsAvailableInteractor,
        mockGetOIDCConfigurationInteractor,
        mockGetTokenOIDCInteractor,
        mockAuthenticateOidcOnBrowserInteractor,
        mockGetAuthenticationInfoInteractor,
        mockGetStoredOidcConfigurationInteractor,
        mockSaveLoginUrlOnMobileInteractor,
        mockGetAllRecentLoginUrlOnMobileInteractor,
        mockSaveLoginUsernameOnMobileInteractor,
        mockGetAllRecentLoginUsernameOnMobileInteractor,
        mockDNSLookupToGetJmapUrlInteractor,
        mockSignInTwakeWorkplaceInteractor,
      );


    });

    test('WHEN handleFailureViewState is called with GetTokenOIDCFailure \n'
        'AND loginFormType is dnsLookup \n'
        'BUT EXCEPTION is not NoSuitableBrowserForOIDCException \n'
        'THEN loginFormType will change', () {

      loginController.loginFormType.value = LoginFormType.dnsLookupForm;
      final failure = GetTokenOIDCFailure(NotFoundUrlException());
      loginController.handleFailureViewState(failure);

      expect(loginController.loginFormType.value, isNot(LoginFormType.dnsLookupForm));
    });

    test('WHEN handleFailureViewState is called with GetTokenOIDCFailure \n'
        'AND loginFormType is dnsLookup \n'
        'BUT EXCEPTION is NoSuitableBrowserForOIDCException \n'
        'THEN loginFormType will not change', () {

      loginController.loginFormType.value = LoginFormType.dnsLookupForm;
      final failure = GetTokenOIDCFailure(NoSuitableBrowserForOIDCException());
      loginController.handleFailureViewState(failure);

      expect(loginController.loginFormType.value, equals(LoginFormType.dnsLookupForm));
    });

    test('WHEN handleFailureViewState is called with GetTokenOIDCFailure \n'
        'AND loginFormType is baseUrlForm \n'
        'BUT EXCEPTION is not NoSuitableBrowserForOIDCException \n'
        'THEN loginFormType will change', () {

      loginController.loginFormType.value = LoginFormType.baseUrlForm;
      final failure = GetTokenOIDCFailure(NotFoundUrlException());
      loginController.handleFailureViewState(failure);

      expect(loginController.loginFormType.value, isNot(LoginFormType.baseUrlForm));
    });

    test('WHEN handleFailureViewState is called with GetTokenOIDCFailure \n'
        'AND loginFormType is baseUrlForm \n'
        'BUT EXCEPTION is NoSuitableBrowserForOIDCException \n'
        'THEN loginFormType will not change', () {

      loginController.loginFormType.value = LoginFormType.baseUrlForm;
      final failure = GetTokenOIDCFailure(NoSuitableBrowserForOIDCException());
      loginController.handleFailureViewState(failure);

      expect(loginController.loginFormType.value, equals(LoginFormType.baseUrlForm));
    });
  });
}