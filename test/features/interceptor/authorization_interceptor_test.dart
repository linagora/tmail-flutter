
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

import '../../fixtures/account_fixtures.dart';
import '../../fixtures/oidc_fixtures.dart';
import 'authorization_interceptor_test.mocks.dart';

@GenerateMocks([
  AuthenticationClientBase,
  TokenOidcCacheManager,
  AccountCacheManager,
  IOSSharingManager
])
void main() {

  late Dio dio;
  late DioAdapter dioAdapter;
  late AuthenticationClientBase authenticationClient;
  late TokenOidcCacheManager tokenOidcCacheManager;
  late AccountCacheManager accountCacheManager;
  late IOSSharingManager iosSharingManager;
  late AuthorizationInterceptors authorizationInterceptors;

  setUp(() {
    final baseOption = BaseOptions(method: 'POST');
    dio = Dio(baseOption)
      ..options.baseUrl = 'http://domain.com';

    authenticationClient = MockAuthenticationClientBase();
    tokenOidcCacheManager = MockTokenOidcCacheManager();
    accountCacheManager = MockAccountCacheManager();
    iosSharingManager = MockIOSSharingManager();

    authorizationInterceptors = AuthorizationInterceptors(
      dio,
      authenticationClient,
      tokenOidcCacheManager,
      accountCacheManager,
      iosSharingManager);

    dio.interceptors.add(authorizationInterceptors);

    dioAdapter = DioAdapter(dio: dio);
  });

  group('AuthorizationInterceptor test', () {
    group("Authorization with OIDC", () {
      test('validateToRefreshToken should return true when conditions are met', () async {
        final dioError401 = DioError(
          requestOptions: RequestOptions(path: '/jmap'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/jmap')));

        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpired,
          newConfig: OIDCFixtures.oidcConfiguration);

        expect(authorizationInterceptors.validateToRefreshToken(dioError401), true);
      });

      test('validateToRefreshToken should return false when conditions are not met', () async {
        final dioError401 = DioError(
          requestOptions: RequestOptions(path: '/jmap'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/jmap')));

        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcWithRefreshTokenEmpty,
          newConfig: OIDCFixtures.oidcConfiguration);

        expect(authorizationInterceptors.validateToRefreshToken(dioError401), false);
      });

      test('refreshingTokensOIDC should be called only once when token expired', () async {
        final dioError401 = DioError(
          requestOptions: RequestOptions(path: '/jmap'),
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/jmap')));

        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpired,
          newConfig: OIDCFixtures.oidcConfiguration);

        when(accountCacheManager.getCurrentAccount()).thenAnswer((_) async => AccountFixtures.oidcAccount);
        when(authorizationInterceptors.invokeRefreshTokenFromServer()).thenAnswer((_) async => OIDCFixtures.tokenOidc);

        authorizationInterceptors.onError(dioError401, ErrorInterceptorHandler());

        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpired.refreshToken,
        )).called(1);
      });
    });
  });

  tearDown(() {
    dioAdapter.close();
    dio.close();
  });
}