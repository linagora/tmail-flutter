import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/account/authentication_type.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_email_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_login_url_cache_interactor.dart';
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_login_username_interactor.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/home/presentation/home_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_stored_token_oidc_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'home_controller_test.mocks.dart';

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
  MockSpec<CleanupEmailCacheInteractor>(),
  MockSpec<CleanupRecentLoginUrlCacheInteractor>(),
  MockSpec<CleanupRecentLoginUsernameCacheInteractor>(),
  MockSpec<EmailReceiveManager>(),
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
  TestWidgetsFlutterBinding.ensureInitialized();

  late HomeController homeController;
  late MockCleanupEmailCacheInteractor cleanupEmailCacheInteractor;
  late MockEmailReceiveManager emailReceiveManager;
  late MockCleanupRecentLoginUrlCacheInteractor cleanupRecentLoginUrlCacheInteractor;
  late MockCleanupRecentLoginUsernameCacheInteractor cleanupRecentLoginUsernameCacheInteractor;

  late MockGetSessionInteractor mockGetSessionInteractor;
  late MockGetAuthenticatedAccountInteractor mockGetAuthenticatedAccountInteractor;
  late MockUpdateAccountCacheInteractor mockUpdateAccountCacheInteractor;

  late MockCachingManager mockCachingManager;
  late MockLanguageCacheManager mockLanguageCacheManager;
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

  setUpAll(() {
    cleanupEmailCacheInteractor = MockCleanupEmailCacheInteractor();
    emailReceiveManager = MockEmailReceiveManager();
    cleanupRecentLoginUrlCacheInteractor = MockCleanupRecentLoginUrlCacheInteractor();
    cleanupRecentLoginUsernameCacheInteractor = MockCleanupRecentLoginUsernameCacheInteractor();

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

    homeController = HomeController(
      cleanupEmailCacheInteractor,
      emailReceiveManager,
      cleanupRecentLoginUrlCacheInteractor,
      cleanupRecentLoginUsernameCacheInteractor
    );
  });

  group("HomeController::onData test", () {
    test("WHEN onData receive `GetStoredTokenOidcFailure` "
      "THEN handleFailureViewState should be called", () {
      // Arrange
      final failure = Left<Failure, Success>(GetStoredTokenOidcFailure(Exception()));
      when(mockAuthorizationInterceptors.authenticationType).thenReturn(AuthenticationType.oidc);

      // Act
      homeController.onData(failure);

      // Assert
      verifyNever(mockAppToast.showToastMessage(any, any));
      verifyNever(mockAppToast.showToastErrorMessage(any, any));
    });
  });
}