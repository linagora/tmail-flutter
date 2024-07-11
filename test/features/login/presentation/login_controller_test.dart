
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
import 'package:tmail_ui_user/features/login/domain/usecases/dns_lookup_to_get_jmap_url_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_all_recent_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_auth_response_url_browser_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_current_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_token_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/logout_current_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_url_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/save_login_username_on_mobile_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_current_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/presentation/login_controller.dart';
import 'package:tmail_ui_user/features/login/presentation/login_form_type.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:uuid/uuid.dart';

import 'login_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<AppToast>(),
  MockSpec<ImagePaths>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<AuthenticationInteractor>(),
  MockSpec<CheckOIDCIsAvailableInteractor>(),
  MockSpec<GetTokenOIDCInteractor>(),
  MockSpec<AuthenticateOidcOnBrowserInteractor>(),
  MockSpec<GetAuthResponseUrlBrowserInteractor>(),
  MockSpec<SaveLoginUrlOnMobileInteractor>(),
  MockSpec<GetAllRecentLoginUrlOnMobileInteractor>(),
  MockSpec<SaveLoginUsernameOnMobileInteractor>(),
  MockSpec<GetAllRecentLoginUsernameOnMobileInteractor>(),
  MockSpec<DNSLookupToGetJmapUrlInteractor>(),
  MockSpec<GetSessionInteractor>(),
  MockSpec<GetCurrentAccountCacheInteractor>(),
  MockSpec<UpdateCurrentAccountCacheInteractor>(),
  MockSpec<LogoutCurrentAccountInteractor>(),
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<ApplicationManager>(),
])
void main() {
  late MockAuthenticationInteractor mockAuthenticationInteractor;
  late MockCheckOIDCIsAvailableInteractor mockCheckOIDCIsAvailableInteractor;
  late MockGetTokenOIDCInteractor mockGetTokenOIDCInteractor;
  late MockAuthenticateOidcOnBrowserInteractor mockAuthenticateOidcOnBrowserInteractor;
  late MockGetAuthResponseUrlBrowserInteractor mockGetAuthResponseUrlBrowserInteractor;
  late MockSaveLoginUrlOnMobileInteractor mockSaveLoginUrlOnMobileInteractor;
  late MockGetAllRecentLoginUrlOnMobileInteractor mockGetAllRecentLoginUrlOnMobileInteractor;
  late MockSaveLoginUsernameOnMobileInteractor mockSaveLoginUsernameOnMobileInteractor;
  late MockGetAllRecentLoginUsernameOnMobileInteractor mockGetAllRecentLoginUsernameOnMobileInteractor;
  late MockDNSLookupToGetJmapUrlInteractor mockDNSLookupToGetJmapUrlInteractor;
  late MockGetSessionInteractor mockGetSessionInteractor;
  late MockGetCurrentAccountCacheInteractor mockGetCurrentAccountCacheInteractor;
  late MockUpdateCurrentAccountCacheInteractor mockUpdateCurrentAccountCacheInteractor;
  late LogoutCurrentAccountInteractor mockLogoutCurrentAccountInteractor;
  late CachingManager mockCachingManager;
  late LanguageCacheManager mockLanguageCacheManager;
  late MockAuthorizationInterceptors mockAuthorizationInterceptors;
  late MockDynamicUrlInterceptors mockDynamicUrlInterceptors;
  late MockAppToast mockAppToast;
  late MockImagePaths mockImagePaths;
  late MockResponsiveUtils mockResponsiveUtils;
  late MockUuid mockUuid;
  late MockApplicationManager mockApplicationManager;

  late LoginController loginController;

  group('Test handleFailureViewState with GetTokenOIDCFailure', () {
    setUp(() {
      mockAuthenticationInteractor = MockAuthenticationInteractor();
      mockCheckOIDCIsAvailableInteractor = MockCheckOIDCIsAvailableInteractor();
      mockGetAuthResponseUrlBrowserInteractor = MockGetAuthResponseUrlBrowserInteractor();
      mockGetTokenOIDCInteractor = MockGetTokenOIDCInteractor();
      mockAuthenticateOidcOnBrowserInteractor = MockAuthenticateOidcOnBrowserInteractor();
      mockSaveLoginUrlOnMobileInteractor = MockSaveLoginUrlOnMobileInteractor();
      mockGetAllRecentLoginUrlOnMobileInteractor = MockGetAllRecentLoginUrlOnMobileInteractor();
      mockSaveLoginUsernameOnMobileInteractor = MockSaveLoginUsernameOnMobileInteractor();
      mockGetAllRecentLoginUsernameOnMobileInteractor = MockGetAllRecentLoginUsernameOnMobileInteractor();
      mockDNSLookupToGetJmapUrlInteractor = MockDNSLookupToGetJmapUrlInteractor();

      // mock reloadable controller
      mockGetSessionInteractor = MockGetSessionInteractor();
      mockGetCurrentAccountCacheInteractor = MockGetCurrentAccountCacheInteractor();
      mockUpdateCurrentAccountCacheInteractor = MockUpdateCurrentAccountCacheInteractor();
      mockLogoutCurrentAccountInteractor = MockLogoutCurrentAccountInteractor();

      //mock base controller
      mockCachingManager = MockCachingManager();
      mockLanguageCacheManager = MockLanguageCacheManager();
      mockAuthorizationInterceptors = MockAuthorizationInterceptors();
      mockDynamicUrlInterceptors = MockDynamicUrlInterceptors();
      mockAppToast = MockAppToast();
      mockImagePaths = MockImagePaths();
      mockResponsiveUtils = MockResponsiveUtils();
      mockUuid = MockUuid();
      mockApplicationManager = MockApplicationManager();

      Get.put<GetSessionInteractor>(mockGetSessionInteractor);
      Get.put<GetCurrentAccountCacheInteractor>(mockGetCurrentAccountCacheInteractor);
      Get.put<UpdateCurrentAccountCacheInteractor>(mockUpdateCurrentAccountCacheInteractor);
      Get.put<LogoutCurrentAccountInteractor>(mockLogoutCurrentAccountInteractor);
      Get.put<CachingManager>(mockCachingManager);
      Get.put<LanguageCacheManager>(mockLanguageCacheManager);
      Get.put<AuthorizationInterceptors>(mockAuthorizationInterceptors);
      Get.put<AuthorizationInterceptors>(
        mockAuthorizationInterceptors,
        tag: BindingTag.isolateTag,
      );
      Get.put<DynamicUrlInterceptors>(mockDynamicUrlInterceptors);

      Get.put<AppToast>(mockAppToast);
      Get.put<ImagePaths>(mockImagePaths);
      Get.put<ResponsiveUtils>(mockResponsiveUtils);
      Get.put<Uuid>(mockUuid);
      Get.put<ApplicationManager>(mockApplicationManager);
      Get.testMode = true;

      loginController = LoginController(
        mockAuthenticationInteractor,
        mockCheckOIDCIsAvailableInteractor,
        mockGetTokenOIDCInteractor,
        mockAuthenticateOidcOnBrowserInteractor,
        mockGetAuthResponseUrlBrowserInteractor,
        mockSaveLoginUrlOnMobileInteractor,
        mockGetAllRecentLoginUrlOnMobileInteractor,
        mockSaveLoginUsernameOnMobileInteractor,
        mockGetAllRecentLoginUsernameOnMobileInteractor,
        mockDNSLookupToGetJmapUrlInteractor,
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