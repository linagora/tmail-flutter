import 'package:contact/contact/model/autocomplete_capability.dart';
import 'package:contact/contact/model/capability_contact.dart';
import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/application_manager.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/account/account.dart';
import 'package:jmap_dart_client/jmap/core/capability/empty_capability.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/unsigned_int.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
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
import 'package:tmail_ui_user/main/utils/app_config.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:uuid/uuid.dart';

import '../../fixtures/account_fixtures.dart';
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
  MockSpec<ToastManager>(),
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
  late MockToastManager mockToastManager;

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
    mockToastManager = MockToastManager();

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

  group('BaseController::getMinInputLengthAutocomplete::test', () {
    late MockBaseController mockBaseController;

    setUp(() {
      mockBaseController = MockBaseController();
    });

    test('SHOULD return session min input length WHEN AutocompleteCapability available', () {
      // Arrange
      const expectedMinInputLength = 5;
      final session = Session(
        {
          tmailContactCapabilityIdentifier: AutocompleteCapability(
            minInputLength: UnsignedInt(expectedMinInputLength)
          )
        },
        {
          AccountFixtures.aliceAccountId: Account(
            AccountName('Alice'),
            true,
            false,
            {
              tmailContactCapabilityIdentifier: AutocompleteCapability(
                minInputLength: UnsignedInt(expectedMinInputLength)
              )
            },
          )
        },
        {},
        UserName(''),
        Uri(),
        Uri(),
        Uri(),
        Uri(),
        State(''));

      // Act
      final result = mockBaseController.getMinInputLengthAutocomplete(
        session: session,
        accountId: AccountFixtures.aliceAccountId,
      );

      // Assert
      expect(result, expectedMinInputLength);
    });

    test('SHOULD return session min input length WHEN AutocompleteCapability available, but no minInputLength', () {
      // Arrange
      const expectedMinInputLength = AppConfig.defaultMinInputLengthAutocomplete;
      final session = Session(
        {
          tmailContactCapabilityIdentifier: AutocompleteCapability()
        },
        {
          AccountFixtures.aliceAccountId: Account(
            AccountName('Alice'),
            true,
            false,
            {
              tmailContactCapabilityIdentifier: AutocompleteCapability()
            },
          )
        },
        {},
        UserName(''),
        Uri(),
        Uri(),
        Uri(),
        Uri(),
        State(''),
      );

      // Act
      final result = mockBaseController.getMinInputLengthAutocomplete(
        session: session,
        accountId: AccountFixtures.aliceAccountId,
      );

      // Assert
      expect(result, expectedMinInputLength);
    });

    test('SHOULD return default min input length WHEN AutocompleteCapability is not available', () {
      // Arrange
      final session = Session(
        {
          tmailContactCapabilityIdentifier: EmptyCapability()
        },
        {
          AccountFixtures.aliceAccountId: Account(
            AccountName('Alice'),
            true,
            false,
            {
              tmailContactCapabilityIdentifier: EmptyCapability()
            },
          )
        },
        {},
        UserName(''),
        Uri(),
        Uri(),
        Uri(),
        Uri(),
        State(''));

      // Act
      final result = mockBaseController.getMinInputLengthAutocomplete(
        session: session,
        accountId: AccountFixtures.aliceAccountId,
      );

      // Assert
      expect(result, AppConfig.defaultMinInputLengthAutocomplete);
    });
  });
}
