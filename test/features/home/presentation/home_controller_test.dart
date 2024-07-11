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
import 'package:tmail_ui_user/features/cleanup/domain/usecases/cleanup_recent_search_cache_interactor.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/home/presentation/home_controller.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/state/get_current_account_cache_state.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_current_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/logout_current_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_current_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/utils/email_receive_manager.dart';
import 'package:uuid/uuid.dart';

import 'home_controller_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<AppToast>(),
  MockSpec<ImagePaths>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
  MockSpec<CleanupEmailCacheInteractor>(),
  MockSpec<CleanupRecentSearchCacheInteractor>(),
  MockSpec<CleanupRecentLoginUrlCacheInteractor>(),
  MockSpec<CleanupRecentLoginUsernameCacheInteractor>(),
  MockSpec<EmailReceiveManager>(),
  MockSpec<GetSessionInteractor>(),
  MockSpec<GetCurrentAccountCacheInteractor>(),
  MockSpec<UpdateCurrentAccountCacheInteractor>(),
  MockSpec<LogoutCurrentAccountInteractor>(),
  MockSpec<CachingManager>(),
  MockSpec<LanguageCacheManager>(),
  MockSpec<ApplicationManager>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late HomeController homeController;
  late MockCleanupEmailCacheInteractor cleanupEmailCacheInteractor;
  late MockEmailReceiveManager emailReceiveManager;
  late MockCleanupRecentSearchCacheInteractor cleanupRecentSearchCacheInteractor;
  late MockCleanupRecentLoginUrlCacheInteractor cleanupRecentLoginUrlCacheInteractor;
  late MockCleanupRecentLoginUsernameCacheInteractor cleanupRecentLoginUsernameCacheInteractor;

  late MockGetSessionInteractor mockGetSessionInteractor;
  late MockGetCurrentAccountCacheInteractor mockGetCurrentAccountCacheInteractor;
  late MockUpdateCurrentAccountCacheInteractor mockUpdateCurrentAccountCacheInteractor;
  late MockLogoutCurrentAccountInteractor mockLogoutCurrentAccountInteractor;

  late MockCachingManager mockCachingManager;
  late MockLanguageCacheManager mockLanguageCacheManager;
  late MockAuthorizationInterceptors mockAuthorizationInterceptors;
  late MockDynamicUrlInterceptors mockDynamicUrlInterceptors;
  late MockAppToast mockAppToast;
  late MockImagePaths mockImagePaths;
  late MockResponsiveUtils mockResponsiveUtils;
  late MockUuid mockUuid;
  late MockApplicationManager mockApplicationManager;

  setUpAll(() {
    cleanupEmailCacheInteractor = MockCleanupEmailCacheInteractor();
    emailReceiveManager = MockEmailReceiveManager();
    cleanupRecentSearchCacheInteractor = MockCleanupRecentSearchCacheInteractor();
    cleanupRecentLoginUrlCacheInteractor = MockCleanupRecentLoginUrlCacheInteractor();
    cleanupRecentLoginUsernameCacheInteractor = MockCleanupRecentLoginUsernameCacheInteractor();

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

    homeController = HomeController(
      cleanupEmailCacheInteractor,
      emailReceiveManager,
      cleanupRecentSearchCacheInteractor,
      cleanupRecentLoginUrlCacheInteractor,
      cleanupRecentLoginUsernameCacheInteractor
    );
  });

  group("HomeController::onData test", () {
    test("WHEN onData receive `GetCurrentAccountCacheFailure` "
      "THEN handleFailureViewState should be called", () {
      // Arrange
      final failure = Left<Failure, Success>(GetCurrentAccountCacheFailure(Exception()));
      when(mockAuthorizationInterceptors.authenticationType).thenReturn(AuthenticationType.oidc);

      // Act
      homeController.onData(failure);

      // Assert
      verifyNever(mockAppToast.showToastMessage(any, any));
      verifyNever(mockAppToast.showToastErrorMessage(any, any));
    });
  });
}