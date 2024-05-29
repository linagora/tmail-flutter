import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/base/base_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/exceptions/remote_exception.dart';
import 'package:uuid/uuid.dart';

import '../email/presentation/controller/single_email_controller_test.mocks.dart';

class TestBaseController extends BaseController {
  bool isLogoutCalled = false;

  @override
  void goToLogin() {
    isLogoutCalled = true;
    super.goToLogin();
  }
}

class TestFeatureFailure extends FeatureFailure {
  TestFeatureFailure({super.exception});
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // mock base controller Get dependencies
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

  late TestBaseController baseController;

  setUp(() {
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
    
    baseController = TestBaseController();

    Get.testMode = true;
  });
  
  group('base controller test:', () {
    test(
      'SHOULD log user out '
      'WHEN any data received is failure '
      'AND the exception is ConnectionError',
    () async {
      // arrange
      when(authorizationInterceptors.isAppRunning).thenReturn(true);

      // act
      baseController.onData(Left(TestFeatureFailure(
        exception: const ConnectionError())));
      await Future.delayed(const Duration(milliseconds: 500));

      // assert
      expect(baseController.isLogoutCalled, true);
    });

    test(
      'SHOULD log user out '
      'WHEN any data received is failure '
      'AND the exception is BadCredentialsException',
    () async {
      // arrange
      when(authorizationInterceptors.isAppRunning).thenReturn(true);

      // act
      baseController.onData(Left(TestFeatureFailure(
        exception: const BadCredentialsException())));
      await Future.delayed(const Duration(milliseconds: 500));

      // assert
      expect(baseController.isLogoutCalled, true);
    });

    test(
      'SHOULD log user out '
      'WHEN the stream consumed throw an exception '
      'AND the exception is ConnectionError',
    () async {
      // arrange
      when(authorizationInterceptors.isAppRunning).thenReturn(true);

      // act
      baseController.onError(
        const ConnectionError(),
        StackTrace.empty);
      await Future.delayed(const Duration(milliseconds: 500));

      // assert
      expect(baseController.isLogoutCalled, true);
    });

    test(
      'SHOULD log user out '
      'WHEN the stream consumed throw an exception '
      'AND the exception is BadCredentialsException',
    () async {
      // arrange
      when(authorizationInterceptors.isAppRunning).thenReturn(true);

      // act
      baseController.onError(
        const BadCredentialsException(),
        StackTrace.empty);
      await Future.delayed(const Duration(milliseconds: 500));

      // assert
      expect(baseController.isLogoutCalled, true);
    });
  });
}