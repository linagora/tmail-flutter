import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:get/get_instance/src/lifecycle.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/attempt_toggle_system_notification_setting_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/get_app_notification_setting_cache_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/state/toggle_app_notification_setting_cache_state.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/attempt_toggle_system_notification_setting_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/get_app_notification_setting_cache_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/toggle_app_notification_setting_cache_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/presentation/notification/notification_controller.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:uuid/uuid.dart';

import 'notification_controller_test.mocks.dart';

mockControllerCallback() => InternalFinalCallback<void>(callback: () {});
const fallbackGenerators = {
  #onStart: mockControllerCallback,
  #onDelete: mockControllerCallback,
};

@GenerateNiceMocks([
  MockSpec<GetAppNotificationSettingCacheInteractor>(),
  MockSpec<ToggleAppNotificationSettingCacheInteractor>(),
  MockSpec<AttemptToggleSystemNotificationSettingInteractor>(),
  MockSpec<CachingManager>(fallbackGenerators: fallbackGenerators),
  MockSpec<LanguageCacheManager>(fallbackGenerators: fallbackGenerators),
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<DynamicUrlInterceptors>(),
  MockSpec<DeleteCredentialInteractor>(),
  MockSpec<LogoutOidcInteractor>(),
  MockSpec<DeleteAuthorityOidcInteractor>(),
  MockSpec<AppToast>(),
  MockSpec<ImagePaths>(),
  MockSpec<ResponsiveUtils>(),
  MockSpec<Uuid>(),
])
void main() {
  final getAppNotificationSettingCacheInteractor 
    = MockGetAppNotificationSettingCacheInteractor();
  final toggleAppNotificationSettingCacheInteractor 
    = MockToggleAppNotificationSettingCacheInteractor();
  final attemptToggleSystemNotificationSettingInteractor 
    = MockAttemptToggleSystemNotificationSettingInteractor();
  late NotificationController notificationController;

  final cachingManager = MockCachingManager();
  final languageCacheManager = MockLanguageCacheManager();
  final authorizationInterceptors = MockAuthorizationInterceptors();
  final dynamicUrlInterceptors = MockDynamicUrlInterceptors();
  final deleteCredentialInteractor = MockDeleteCredentialInteractor();
  final logoutOidcInteractor = MockLogoutOidcInteractor();
  final deleteAuthorityOidcInteractor = MockDeleteAuthorityOidcInteractor();
  final appToast = MockAppToast();
  final imagePaths = MockImagePaths();
  final responsiveUtils = MockResponsiveUtils();
  final uuid = MockUuid();

  setUpAll(() {
    Get.put<CachingManager>(cachingManager);
    Get.put<LanguageCacheManager>(languageCacheManager);
    Get.put<AuthorizationInterceptors>(authorizationInterceptors);
    Get.put<AuthorizationInterceptors>(
      authorizationInterceptors,
      tag: BindingTag.isolateTag,
    );
    Get.put<DynamicUrlInterceptors>(dynamicUrlInterceptors);
    Get.put<DeleteCredentialInteractor>(deleteCredentialInteractor);
    Get.put<LogoutOidcInteractor>(logoutOidcInteractor);
    Get.put<DeleteAuthorityOidcInteractor>(deleteAuthorityOidcInteractor);
    Get.put<AppToast>(appToast);
    Get.put<ImagePaths>(imagePaths);
    Get.put<ResponsiveUtils>(responsiveUtils);
    Get.put<Uuid>(uuid);
  });

  setUp(() {
    notificationController = NotificationController(
      getAppNotificationSettingCacheInteractor,
      toggleAppNotificationSettingCacheInteractor,
      attemptToggleSystemNotificationSettingInteractor);
  });

  group('notification controller test', () {
    test(
      'should call execute on getAppNotificationSettingCacheInteractor '
      'when init',
    () {
      // act
      notificationController.onInit();
      
      // assert
      verify(getAppNotificationSettingCacheInteractor.execute()).called(1);
    });

    test(
      'should call execute on toggleAppNotificationSettingCacheInteractor '
      'when toggleAppNotificationSetting is triggered',
    () {
      // arrange
      notificationController.appNotificationSettingEnabled.value = true;

      // act
      notificationController.toggleAppNotificationSetting();
      
      // assert
      verify(toggleAppNotificationSettingCacheInteractor.execute(false)).called(1);
    });

    test(
      'should change the value of appNotificationSettingEnabled '
      'when GetAppNotificationSettingCacheSuccess is emitted',
    () {
      // arrange
      notificationController.handleSuccessViewState(GetAppNotificationSettingCacheSuccess(true));
      
      // assert
      expect(notificationController.appNotificationSettingEnabled.value, true);
    });

    test(
      'should change the value of appNotificationSettingEnabled '
      'when AttemptToggleSystemNotificationSettingSuccess is emitted',
    () {
      // arrange
      notificationController.handleSuccessViewState(GetAppNotificationSettingCacheSuccess(false));
      
      // assert
      expect(notificationController.appNotificationSettingEnabled.value, false);
    });

    test(
      'should change the value of appNotificationSettingEnabled '
      'when ToggleAppNotificationSettingCacheSuccess is emitted',
    () {
      // arrange
      notificationController.appNotificationSettingEnabled.value = true;
      notificationController.handleSuccessViewState(ToggleAppNotificationSettingCacheSuccess());
      
      // assert
      expect(notificationController.appNotificationSettingEnabled.value, false);
    });

    test(
      'should change the value of appNotificationSettingEnabled to false '
      'when GetAppNotificationSettingCacheFailure is emitted',
    () {
      // arrange
      notificationController.handleFailureViewState(GetAppNotificationSettingCacheFailure());
      
      // assert
      expect(notificationController.appNotificationSettingEnabled.value, false);
    });

    test(
      'should change the value of appNotificationSettingEnabled to false '
      'when AttemptToggleSystemNotificationSettingFailure is emitted',
    () {
      // arrange
      notificationController.handleFailureViewState(AttemptToggleSystemNotificationSettingFailure());
      
      // assert
      expect(notificationController.appNotificationSettingEnabled.value, false);
    });
  });
}