import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/annotations.dart';
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

import 'base_controller_test.mocks.dart';

class MockBaseController extends BaseController {

  bool isUrgentExceptionEnable = false;
  bool isErrorViewStateEnable = false;

  void resetState() {
     isUrgentExceptionEnable = false;
     isErrorViewStateEnable = false;
  }

  @override
  void handleErrorViewState(Object error, StackTrace stackTrace) {
    super.handleErrorViewState(error, stackTrace);
    isErrorViewStateEnable = true;
  }

  @override
  void handleUrgentException({Failure? failure, Exception? exception}) {
    super.handleUrgentException(failure: failure, exception: exception);
    isUrgentExceptionEnable = true;
  }
}

class SomeOtherException extends RemoteException {}

@GenerateNiceMocks([
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
  MockSpec<ApplicationManager>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockBaseController mockBaseController;
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

  setUpAll(() {
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
    Get.testMode = true;

    mockBaseController = MockBaseController();
  });

  group('BaseController::validateUrgentException', () {
    test('should return true when exception is NoNetworkError', () {
      expect(mockBaseController.validateUrgentException(const NoNetworkError()), isTrue);
    });

    test('should return true when exception is BadCredentialsException', () {
      expect(mockBaseController.validateUrgentException(const BadCredentialsException()), isTrue);
    });

    test('should return true when exception is ConnectionError', () {
      expect(mockBaseController.validateUrgentException(const ConnectionError()), isTrue);
    });

    test('should return false when exception is SomeOtherException', () {
      expect(mockBaseController.validateUrgentException(SomeOtherException()), isFalse);
    });

    test('should return false when exception is null', () {
      expect(mockBaseController.validateUrgentException(null), isFalse);
    });

    test('should return false when exceptions are other types', () {
      expect(mockBaseController.validateUrgentException('StringException'), isFalse);
      expect(mockBaseController.validateUrgentException(123), isFalse);
      expect(mockBaseController.validateUrgentException(Object()), isFalse);
    });
  });

  group('BaseController::onError', () {
    test('handleUrgentException should called when error is NoNetworkError', () {
      // arrange
      const error = NoNetworkError();
      final stackTrace = StackTrace.current;

      // act
      mockBaseController.resetState();
      mockBaseController.onError(error, stackTrace);

      // assert
      expect(mockBaseController.isUrgentExceptionEnable, true);
      expect(mockBaseController.isErrorViewStateEnable, false);
    });

    test('handleUrgentException should called when error is BadCredentialsException', () {
      // arrange
      const error = BadCredentialsException();
      final stackTrace = StackTrace.current;

      // act
      mockBaseController.resetState();
      mockBaseController.onError(error, stackTrace);

      // assert
      expect(mockBaseController.isUrgentExceptionEnable, true);
      expect(mockBaseController.isErrorViewStateEnable, false);
    });

    test('handleUrgentException should called when error is ConnectionError', () {
      // arrange
      const error = ConnectionError();
      final stackTrace = StackTrace.current;

      // act
      mockBaseController.resetState();
      mockBaseController.onError(error, stackTrace);

      // assert
      expect(mockBaseController.isUrgentExceptionEnable, true);
      expect(mockBaseController.isErrorViewStateEnable, false);
    });

    test('handleErrorViewState should called when error is SomeOtherException', () {
      // arrange
      final error = SomeOtherException();
      final stackTrace = StackTrace.current;

      // act
      mockBaseController.resetState();
      mockBaseController.onError(error, stackTrace);

      // assert
      expect(mockBaseController.isErrorViewStateEnable, true);
      expect(mockBaseController.isUrgentExceptionEnable, false);
    });
  });
}
