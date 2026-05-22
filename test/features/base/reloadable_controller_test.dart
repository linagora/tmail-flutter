import 'package:core/data/network/config/dynamic_url_interceptors.dart';
import 'package:core/presentation/resources/image_paths.dart';
import 'package:core/presentation/utils/app_toast.dart';
import 'package:core/presentation/utils/responsive_utils.dart';
import 'package:core/utils/platform_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:jmap_dart_client/jmap/core/session/session.dart';
import 'package:mockito/annotations.dart';
import 'package:tmail_ui_user/features/base/reloadable/reloadable_controller.dart';
import 'package:tmail_ui_user/features/caching/caching_manager.dart';
import 'package:tmail_ui_user/features/home/domain/state/get_session_state.dart';
import 'package:tmail_ui_user/features/home/domain/usecases/get_session_interactor.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_authority_oidc_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/delete_credential_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_authenticated_account_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/get_oidc_user_info_interactor.dart';
import 'package:tmail_ui_user/features/login/domain/usecases/update_account_cache_interactor.dart';
import 'package:tmail_ui_user/features/manage_account/data/local/language_cache_manager.dart';
import 'package:tmail_ui_user/features/manage_account/domain/usecases/log_out_oidc_interactor.dart';
import 'package:tmail_ui_user/features/home/data/exceptions/session_exceptions.dart';
import 'package:tmail_ui_user/main/bindings/network/binding_tag.dart';
import 'package:tmail_ui_user/main/exceptions/cache/cache_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/main/exceptions/remote/network_exception.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:tmail_ui_user/main/utils/twake_app_manager.dart';
import 'package:uuid/uuid.dart';

import 'reloadable_controller_test.mocks.dart';

class _TestReloadableController extends ReloadableController {
  bool wasLoggedOut = false;

  @override
  Future<void> clearDataAndGoToLoginPage() async {
    wasLoggedOut = true;
  }

  @override
  void handleReloaded(Session session) {}
}

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
  MockSpec<ToastManager>(),
  MockSpec<TwakeAppManager>(),
  MockSpec<GetSessionInteractor>(),
  MockSpec<GetAuthenticatedAccountInteractor>(),
  MockSpec<UpdateAccountCacheInteractor>(),
  MockSpec<GetOidcUserInfoInteractor>(),
])
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _TestReloadableController controller;

  setUpAll(() {
    Get.put<CachingManager>(MockCachingManager());
    Get.put<LanguageCacheManager>(MockLanguageCacheManager());
    Get.put<AuthorizationInterceptors>(MockAuthorizationInterceptors());
    Get.put<AuthorizationInterceptors>(
      MockAuthorizationInterceptors(),
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
    Get.put<GetAuthenticatedAccountInteractor>(MockGetAuthenticatedAccountInteractor());
    Get.put<UpdateAccountCacheInteractor>(MockUpdateAccountCacheInteractor());
    Get.put<GetOidcUserInfoInteractor>(MockGetOidcUserInfoInteractor());

    Get.testMode = true;
    controller = _TestReloadableController();
  });

  setUp(() {
    controller.wasLoggedOut = false;
  });

  group('Bug 2 — mobile: handleGetSessionFailure does NOT log out on transient network error', () {
    setUp(() {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      controller.wasLoggedOut = false;
    });

    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test(
      'WHEN GetSessionFailure carries ConnectionTimeout on mobile\n'
      'THEN clearDataAndGoToLoginPage MUST NOT be called',
      () {
        controller.handleGetSessionFailure(GetSessionFailure(const ConnectionTimeout()));

        expect(controller.wasLoggedOut, isFalse);
      },
    );

    test(
      'WHEN GetSessionFailure carries SocketError on mobile\n'
      'THEN clearDataAndGoToLoginPage MUST NOT be called',
      () {
        controller.handleGetSessionFailure(GetSessionFailure(const SocketError()));

        expect(controller.wasLoggedOut, isFalse);
      },
    );

    test(
      'WHEN GetSessionFailure carries NoNetworkError on mobile\n'
      'THEN clearDataAndGoToLoginPage MUST NOT be called',
      () {
        controller.handleGetSessionFailure(GetSessionFailure(const NoNetworkError()));

        expect(controller.wasLoggedOut, isFalse);
      },
    );

    test(
      'WHEN GetSessionFailure carries ConnectionError on mobile\n'
      'THEN clearDataAndGoToLoginPage MUST NOT be called',
      () {
        controller.handleGetSessionFailure(GetSessionFailure(const ConnectionError()));

        expect(controller.wasLoggedOut, isFalse);
      },
    );

    test(
      'WHEN GetSessionFailure carries BadCredentialsException on mobile\n'
      'THEN clearDataAndGoToLoginPage MUST be called\n'
      '(real auth failure — logout is correct)',
      () {
        controller.handleGetSessionFailure(GetSessionFailure(const BadCredentialsException()));

        expect(controller.wasLoggedOut, isTrue);
      },
    );

    test(
      'WHEN GetSessionFailure carries RefreshTokenFailedException on mobile\n'
      'THEN clearDataAndGoToLoginPage MUST be called',
      () {
        controller.handleGetSessionFailure(GetSessionFailure(RefreshTokenFailedException()));

        expect(controller.wasLoggedOut, isTrue);
      },
    );

    test(
      'WHEN GetSessionFailure carries UnknownCacheError on mobile\n'
      'THEN clearDataAndGoToLoginPage MUST NOT be called\n'
      '(cache read error is not an auth failure)',
      () {
        controller.handleGetSessionFailure(GetSessionFailure(const UnknownCacheError()));

        expect(controller.wasLoggedOut, isFalse);
      },
    );

    test(
      'WHEN GetSessionFailure carries NotFoundSessionException on mobile\n'
      'THEN clearDataAndGoToLoginPage MUST be called\n'
      '(no cached session means user must re-authenticate)',
      () {
        controller.handleGetSessionFailure(GetSessionFailure(NotFoundSessionException()));

        expect(controller.wasLoggedOut, isTrue);
      },
    );
  });

  group('Bug 2 — web: handleGetSessionFailure does NOT log out on transient network error', () {
    setUp(() {
      PlatformInfo.isTestingForWeb = true;
      controller.wasLoggedOut = false;
    });

    tearDown(() {
      PlatformInfo.isTestingForWeb = false;
    });

    test(
      'WHEN GetSessionFailure carries ConnectionTimeout on web\n'
      'THEN clearDataAndGoToLoginPage MUST NOT be called\n'
      '(network guard applies to all platforms)',
      () {
        controller.handleGetSessionFailure(GetSessionFailure(const ConnectionTimeout()));

        expect(controller.wasLoggedOut, isFalse);
      },
    );

    test(
      'WHEN GetSessionFailure carries SocketError on web\n'
      'THEN clearDataAndGoToLoginPage MUST NOT be called',
      () {
        controller.handleGetSessionFailure(GetSessionFailure(const SocketError()));

        expect(controller.wasLoggedOut, isFalse);
      },
    );

    test(
      'WHEN GetSessionFailure carries BadCredentialsException on web\n'
      'THEN clearDataAndGoToLoginPage MUST be called',
      () {
        controller.handleGetSessionFailure(GetSessionFailure(const BadCredentialsException()));

        expect(controller.wasLoggedOut, isTrue);
      },
    );
  });
}
