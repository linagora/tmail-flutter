import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart' hide Response;
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/composer/presentation/providers/composer_attachment_extension_registry_provider.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/oauth_authorization_error.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/presentation/controller/mailbox_dashboard_controller.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/main/providers/workplace/drive_attachment_uri_value_notifier_provider.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';
import 'package:tmail_ui_user/main/utils/toast_manager.dart';
import 'package:workplace/presentation/extension/workplace_composer_attachment_extension.dart';
import 'package:workplace/presentation/model/drive_pick_state.dart';

import '../../../../fixtures/oidc_fixtures.dart';
import 'composer_attachment_extension_registry_provider_test.mocks.dart';

@GenerateNiceMocks([
  MockSpec<AuthorizationInterceptors>(),
  MockSpec<MailboxDashBoardController>(),
  MockSpec<ToastManager>(),
  MockSpec<AuthenticationClientBase>(),
  MockSpec<TokenOidcCacheManager>(),
  MockSpec<AccountCacheManager>(),
  MockSpec<IOSSharingManager>(),
])
void main() {
  late MockAuthorizationInterceptors interceptor;
  late MockMailboxDashBoardController dashboard;
  late MockToastManager toastManager;
  late ProviderContainer container;

  final transientError = DioException(
    requestOptions: RequestOptions(path: '/token'),
    type: DioExceptionType.connectionTimeout,
  );

  WorkplaceComposerAttachmentExtension readExtension() =>
      container.read(composerAttachmentExtensionRegistryProvider).extensions.single
          as WorkplaceComposerAttachmentExtension;

  setUp(() {
    interceptor = MockAuthorizationInterceptors();
    dashboard = MockMailboxDashBoardController();
    toastManager = MockToastManager();
    // Get.put/Get.reset run the GetX lifecycle; the mock's fakes would throw.
    when(dashboard.onStart).thenReturn(InternalFinalCallback<void>(callback: () {}));
    when(dashboard.onDelete).thenReturn(InternalFinalCallback<void>(callback: () {}));
    Get.put<AuthorizationInterceptors>(interceptor);
    Get.put<MailboxDashBoardController>(dashboard);
    Get.put<ToastManager>(toastManager);
    container = ProviderContainer(overrides: [
      driveAttachmentUriValueProvider.overrideWithValue(ValueNotifier<Uri?>(null)),
    ]);
  });

  tearDown(() {
    container.dispose();
    Get.reset();
  });

  group('oidcRefreshTrigger::', () {
    test('returns the refreshed id token on success', () async {
      when(interceptor.requestTokenRefresh()).thenAnswer(
        (_) async => TokenOIDC('access', TokenId('id-token-2'), 'refresh'),
      );

      final token = await readExtension().oidcRefreshTrigger!();

      expect(token, equals('id-token-2'));
      verifyNever(interceptor.clear());
      verifyNever(dashboard.handleRefreshTokenFailedException());
    });

    test('rethrows a fatal rejection untouched; the interceptor already owns clear and classification', () async {
      final rejection = RefreshTokenFailedException();
      when(interceptor.requestTokenRefresh()).thenThrow(rejection);

      await expectLater(
        readExtension().oidcRefreshTrigger!(),
        throwsA(same(rejection)),
      );

      verifyNever(interceptor.clear());
      verifyNever(dashboard.handleRefreshTokenFailedException());
    });

    test('rethrows a transient failure untouched', () async {
      when(interceptor.requestTokenRefresh()).thenThrow(transientError);

      await expectLater(
        readExtension().oidcRefreshTrigger!(),
        throwsA(same(transientError)),
      );

      verifyNever(interceptor.clear());
      verifyNever(dashboard.handleRefreshTokenFailedException());
    });

    test('returns null without logout when no interceptor is registered', () async {
      Get.delete<AuthorizationInterceptors>();

      final token = await readExtension().oidcRefreshTrigger!();

      expect(token, isNull);
      verifyNever(dashboard.handleRefreshTokenFailedException());
    });
  });

  // Real interceptor: proves a server rejection surfaced by the real refresh
  // path reaches the fatal branch, and that a JMAP 401 racing the Workplace
  // callback joins the same in-flight refresh.
  group('oidcRefreshTrigger with real AuthorizationInterceptors::', () {
    const baseUrl = 'http://domain.com/jmap';
    late Dio dio;
    late DioAdapter dioAdapter;
    late MockAuthenticationClientBase authenticationClient;
    late AuthorizationInterceptors realInterceptor;
    late Completer<TokenOIDC> refreshCompleter;

    setUp(() {
      dotenv.testLoad(mergeWith: {'PLATFORM': 'other'});
      dio = Dio(BaseOptions(baseUrl: baseUrl));
      authenticationClient = MockAuthenticationClientBase();
      realInterceptor = AuthorizationInterceptors(
        dio,
        authenticationClient,
        MockTokenOidcCacheManager(),
        MockAccountCacheManager(),
        MockIOSSharingManager(),
      );
      dio.interceptors.add(realInterceptor);
      dioAdapter = DioAdapter(dio: dio);
      Get.delete<AuthorizationInterceptors>(force: true);
      Get.put<AuthorizationInterceptors>(realInterceptor);

      realInterceptor.setTokenAndAuthorityOidc(
        newToken: OIDCFixtures.tokenOidcExpiredTime,
        newConfig: OIDCFixtures.oidcConfiguration,
      );
      dioAdapter.onPost(
        baseUrl,
        (server) => server.throws(
          401,
          DioException(
            requestOptions: RequestOptions(path: baseUrl, method: 'POST'),
            response: Response(
              statusCode: 401,
              requestOptions: RequestOptions(path: baseUrl),
            ),
            type: DioExceptionType.badResponse,
          ),
        ),
        headers: {
          HttpHeaders.authorizationHeader:
              'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
        },
      );
      refreshCompleter = Completer<TokenOIDC>();
      when(authenticationClient.refreshingTokensOIDC(
        OIDCFixtures.oidcConfiguration.clientId,
        OIDCFixtures.oidcConfiguration.redirectUrl,
        OIDCFixtures.oidcConfiguration.discoveryUrl,
        OIDCFixtures.oidcConfiguration.scopes,
        OIDCFixtures.tokenOidcExpiredTime.refreshToken,
      )).thenAnswer((_) => refreshCompleter.future);
    });

    test('fatal refresh racing a JMAP 401 refreshes once and kills the session once', () async {
      // Matchers attach first so neither rejection is reported as unhandled.
      final libRequest = expectLater(
        dio.post(baseUrl),
        throwsA(isA<DioException>().having(
          (e) => e.error, 'error', isA<RefreshTokenFailedException>(),
        )),
      );
      Object? workplaceError;
      final workplaceRefresh = readExtension()
          .oidcRefreshTrigger!()
          .then<String?>((_) => null, onError: (Object e) {
            workplaceError = e;
            return null;
          });
      // Let both callers reach the in-flight refresh before it is rejected.
      await pumpEventQueue();
      refreshCompleter.completeError(const OAuthAuthorizationError(
        error: 'invalid_grant',
        errorDescription: 'The refresh token has been revoked',
      ));
      await Future.wait([libRequest, workplaceRefresh]);

      verify(authenticationClient.refreshingTokensOIDC(any, any, any, any, any)).called(1);
      expect(realInterceptor.authenticationType, AuthenticationType.none);
      expect(workplaceError, isA<RefreshTokenFailedException>());

      // The Drive picker reports that rejection as a DrivePickFailure; the
      // registry must hand it to the dashboard's BaseController path, not toast.
      final failure = DrivePickFailure(workplaceError!);
      when(dashboard.validateUrgentException(workplaceError)).thenReturn(true);
      await readExtension().onPickState!(null, failure);

      verify(dashboard.handleUrgentException(
        failure: failure,
        exception: workplaceError as Exception,
      )).called(1);
      verifyNever(toastManager.showMessageFailure(any));
    });

    test('transient refresh failure racing a JMAP 401 keeps the session', () async {
      const transient = ServerError();
      final libRequest = expectLater(
        dio.post(baseUrl),
        throwsA(isA<DioException>().having((e) => e.error, 'error', same(transient))),
      );
      final workplaceRefresh = expectLater(
        readExtension().oidcRefreshTrigger!(),
        throwsA(same(transient)),
      );
      await pumpEventQueue();
      refreshCompleter.completeError(transient);
      await Future.wait([libRequest, workplaceRefresh]);

      verify(authenticationClient.refreshingTokensOIDC(any, any, any, any, any)).called(1);
      expect(realInterceptor.authenticationType, AuthenticationType.oidc);
    });
  });

  group('onPickState::', () {
    test('transient Drive failure is reported once by the picker layer', () async {
      final failure = DrivePickFailure(transientError);
      when(dashboard.validateUrgentException(transientError)).thenReturn(false);

      await readExtension().onPickState!(null, failure);

      verify(toastManager.showMessageFailure(failure)).called(1);
      verifyNever(dashboard.handleUrgentException(
        failure: anyNamed('failure'),
        exception: anyNamed('exception'),
      ));
    });

    test('urgent failure takes the dashboard BaseController path instead of a toast', () async {
      final rejection = RefreshTokenFailedException();
      final failure = DrivePickFailure(rejection);
      when(dashboard.validateUrgentException(rejection)).thenReturn(true);

      await readExtension().onPickState!(null, failure);

      verify(dashboard.handleUrgentException(failure: failure, exception: rejection)).called(1);
      verifyNever(toastManager.showMessageFailure(any));
    });
  });
}
