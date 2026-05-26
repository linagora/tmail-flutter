
import 'dart:io';

import 'package:core/data/constants/constant.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:core/utils/platform_info.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/password.dart';
import 'package:model/account/personal_account.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_appauth_platform_interface/flutter_appauth_platform_interface.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/oauth_authorization_error.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_session.dart';
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

  const baseUrl = 'http://domain.com/jmap';
  const responseStatusCode200 = 200;
  const responseStatusCode401 = 401;
  const responseStatusCode500 = 500;

  DioException makeDioError401({String path = baseUrl}) => DioException(
    error: {'message': 'Token Expired'},
    requestOptions: RequestOptions(path: path, method: 'POST'),
    response: Response(
      statusCode: responseStatusCode401,
      requestOptions: RequestOptions(path: path),
    ),
    type: DioExceptionType.badResponse,
  );

  final dioErrorRefresh400 = DioException(
    error: {
      'error': 'invalid_grant',
      'error_description': 'Refresh token expired',
    },
    requestOptions: RequestOptions(path: '/token', method: 'POST'),
    response: Response(
      statusCode: 400,
      requestOptions: RequestOptions(path: '/token'),
      data: {'error': 'invalid_grant'},
    ),
    type: DioExceptionType.badResponse,
  );

  final dataRequestSuccessfully = {'message': 'Request successfully!'};

  setUp(() {
    final headers = <String, dynamic>{
      HttpHeaders.acceptHeader: DioClient.jmapHeader,
      HttpHeaders.contentTypeHeader: Constant.contentTypeHeaderDefault,
    };
    final baseOption = BaseOptions(headers: headers);

    dio = Dio(baseOption)..options.baseUrl = baseUrl;

    authenticationClient = MockAuthenticationClientBase();
    tokenOidcCacheManager = MockTokenOidcCacheManager();
    accountCacheManager = MockAccountCacheManager();
    iosSharingManager = MockIOSSharingManager();

    authorizationInterceptors = AuthorizationInterceptors(
      dio,
      authenticationClient,
      tokenOidcCacheManager,
      accountCacheManager,
      iosSharingManager,
    );
    authorizationInterceptors.clear();

    dio.interceptors.add(authorizationInterceptors);

    dioAdapter = DioAdapter(dio: dio);
    dioAdapter.reset();

    dotenv.testLoad(mergeWith: {'PLATFORM': 'other'});
  });

  void stubAccountCache() {
    var callCount = 0;
    when(accountCacheManager.getCurrentAccount()).thenAnswer((_) async {
      callCount++;
      if (callCount == 1) return AccountFixtures.aliceAccount;
      // Second call is the read-back in _verifyStoreTokenAndAccount.
      // Return the PersonalAccount that _updateCurrentAccount would have
      // constructed from newTokenOidc so the equality check passes.
      return PersonalAccount(
        OIDCFixtures.newTokenOidc.tokenIdHash,
        AuthenticationType.oidc,
        isSelected: true,
        accountId: AccountFixtures.aliceAccountId,
        apiUrl: AccountFixtures.aliceAccount.apiUrl,
        userName: AccountFixtures.aliceAccount.userName,
      );
    });
    when(accountCacheManager.deleteCurrentAccount(
      AccountFixtures.aliceAccount.id,
    )).thenAnswer((_) async {});
    when(tokenOidcCacheManager.getTokenOidc(OIDCFixtures.newTokenOidc.tokenIdHash))
        .thenAnswer((_) async => OIDCFixtures.newTokenOidc);
  }

  // ============================================================
  // validateToRefreshToken
  // ============================================================
  group('validateToRefreshToken', () {
    test(
      'should return TRUE when 401 + OIDC + has token + has refreshToken (expired)',
      () {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        final result = authorizationInterceptors.validateToRefreshToken(
          responseStatusCode: responseStatusCode401,
          tokenOIDC: OIDCFixtures.tokenOidcExpiredTime,
        );

        expect(result, true);
      },
    );

    test(
      'should return TRUE when 401 + OIDC + token NOT expired',
      () {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcNotExpiredYet,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        final result = authorizationInterceptors.validateToRefreshToken(
          responseStatusCode: responseStatusCode401,
          tokenOIDC: OIDCFixtures.tokenOidcNotExpiredYet,
        );

        expect(result, true);
      },
    );

    test('should return FALSE when status code is 500 (not 401)', () {
      authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: OIDCFixtures.tokenOidcExpiredTime,
        newConfig: OIDCFixtures.oidcConfiguration,
      );

      final result = authorizationInterceptors.validateToRefreshToken(
        responseStatusCode: responseStatusCode500,
        tokenOIDC: OIDCFixtures.tokenOidcExpiredTime,
      );

      expect(result, false);
    });

    test('should return FALSE when OidcConfiguration is null', () {
      authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: OIDCFixtures.tokenOidcExpiredTime,
        newConfig: null,
      );

      final result = authorizationInterceptors.validateToRefreshToken(
        responseStatusCode: responseStatusCode401,
        tokenOIDC: OIDCFixtures.tokenOidcExpiredTime,
      );

      expect(result, false);
    });

    test('should return FALSE when token is empty', () {
      authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: OIDCFixtures.tokenOidcExpiredTimeAndTokenEmpty,
        newConfig: OIDCFixtures.oidcConfiguration,
      );

      final result = authorizationInterceptors.validateToRefreshToken(
        responseStatusCode: responseStatusCode401,
        tokenOIDC: OIDCFixtures.tokenOidcExpiredTimeAndTokenEmpty,
      );

      expect(result, false);
    });

    test('should return FALSE when refreshToken is empty', () {
      authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: OIDCFixtures.tokenOidcExpiredTimeAndRefreshTokenEmpty,
        newConfig: OIDCFixtures.oidcConfiguration,
      );

      final result = authorizationInterceptors.validateToRefreshToken(
        responseStatusCode: responseStatusCode401,
        tokenOIDC: OIDCFixtures.tokenOidcExpiredTimeAndRefreshTokenEmpty,
      );

      expect(result, false);
    });

    test('should return FALSE when authenticationType is basic', () {
      authorizationInterceptors.setBasicAuthorization(
        UserName('alice'),
        Password('password'),
      );

      final result = authorizationInterceptors.validateToRefreshToken(
        responseStatusCode: responseStatusCode401,
        tokenOIDC: OIDCFixtures.tokenOidcExpiredTime,
      );

      expect(result, false);
    });
  });

  // ============================================================
  // validateToRetryTheRequestWithNewToken
  // ============================================================
  group('validateToRetryTheRequestWithNewToken', () {
    test(
      'should return TRUE when 401, auth header present, token updated, and token not expired',
      () {
        final result =
            authorizationInterceptors.validateToRetryTheRequestWithNewToken(
          responseStatusCode: 401,
          authHeader: 'Bearer old_token',
          tokenOIDC: OIDCFixtures.newTokenOidc,
        );

        expect(result, true);
      },
    );

    test('should return FALSE when status code is not 401 (e.g. 500)', () {
      final result =
          authorizationInterceptors.validateToRetryTheRequestWithNewToken(
        responseStatusCode: 500,
        authHeader: 'Bearer old_token',
        tokenOIDC: OIDCFixtures.newTokenOidc,
      );

      expect(result, false);
    });

    test('should return FALSE when status code is null', () {
      final result =
          authorizationInterceptors.validateToRetryTheRequestWithNewToken(
        responseStatusCode: null,
        authHeader: 'Bearer old_token',
        tokenOIDC: OIDCFixtures.newTokenOidc,
      );

      expect(result, false);
    });

    test('should return FALSE when auth header is null', () {
      final result =
          authorizationInterceptors.validateToRetryTheRequestWithNewToken(
        responseStatusCode: 401,
        authHeader: null,
        tokenOIDC: OIDCFixtures.newTokenOidc,
      );

      expect(result, false);
    });

    test(
      'should return FALSE when token is same as in auth header (not updated)',
      () {
        final result =
            authorizationInterceptors.validateToRetryTheRequestWithNewToken(
          responseStatusCode: 401,
          authHeader: 'Bearer ${OIDCFixtures.newTokenOidc.token}',
          tokenOIDC: OIDCFixtures.newTokenOidc,
        );

        expect(result, false);
      },
    );

    test('should return FALSE when token is expired', () {
      final result =
          authorizationInterceptors.validateToRetryTheRequestWithNewToken(
        responseStatusCode: 401,
        authHeader: 'Bearer some_other_token',
        tokenOIDC: OIDCFixtures.tokenOidcExpiredTime,
      );

      expect(result, false);
    });

    test('should return FALSE when token is empty', () {
      final result =
          authorizationInterceptors.validateToRetryTheRequestWithNewToken(
        responseStatusCode: 401,
        authHeader: 'Bearer some_token',
        tokenOIDC: OIDCFixtures.tokenOidcExpiredTimeAndTokenEmpty,
      );

      expect(result, false);
    });

    test('should return FALSE when tokenOIDC is null', () {
      final result =
          authorizationInterceptors.validateToRetryTheRequestWithNewToken(
        responseStatusCode: 401,
        authHeader: 'Bearer some_token',
        tokenOIDC: null,
      );

      expect(result, false);
    });
  });

  // ============================================================
  // onError: refresh and retry flow
  // ============================================================
  group('onError: refresh and retry flow', () {
    test(
      'WHEN 401 with expired token\n'
      'THEN refresh returns new token\n'
      'AND retry succeeds with 200',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        dioAdapter.onPost(
          baseUrl,
          (server) =>
              server.reply(responseStatusCode200, dataRequestSuccessfully),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        final response = await dio.post(baseUrl);

        expect(response.statusCode, responseStatusCode200);
        expect(response.data, dataRequestSuccessfully);

        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).called(1);
      },
    );

    test(
      'WHEN 401 with NOT-expired token (server-side revocation)\n'
      'THEN refresh returns new token\n'
      'AND retry succeeds with 200',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcNotExpiredYet,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcNotExpiredYet.token}',
          },
        );
        dioAdapter.onPost(
          baseUrl,
          (server) =>
              server.reply(responseStatusCode200, dataRequestSuccessfully),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcNotExpiredYet.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        final response = await dio.post(baseUrl);

        expect(response.statusCode, responseStatusCode200);
        expect(response.data, dataRequestSuccessfully);

        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcNotExpiredYet.refreshToken,
        )).called(1);
      },
    );

    test(
      'WHEN 401 and refresh returns same token (duplicate)\n'
      'THEN propagate original 401 error without retrying',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.tokenOidcExpiredTime);
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>(
            (e) => e.response?.statusCode == responseStatusCode401,
          )),
        );
      },
    );
  });

  // ============================================================
  // onError: refresh fails with DioException
  // ============================================================
  group('onError: refresh fails with DioException', () {
    test(
      'WHEN refresh fails with 400 (Invalid Grant)\n'
      'THEN reject with RefreshTokenFailedException\n'
      'AND clear interceptor state',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(dioErrorRefresh400);
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>((e) {
            return e.type == DioExceptionType.badResponse &&
                e.error is RefreshTokenFailedException &&
                e.response?.statusCode == 400;
          })),
        );

        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).called(1);

        expect(
          authorizationInterceptors.authenticationType,
          AuthenticationType.none,
        );
      },
    );

    test(
      'WHEN refresh fails with 401 DioException\n'
      'THEN propagate refreshError directly (not stale 401)\n'
      'AND OIDC state is NOT cleared',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );

        final dioErrorRefresh401 = DioException(
          requestOptions: RequestOptions(path: '/token'),
          response: Response(
            statusCode: responseStatusCode401,
            requestOptions: RequestOptions(path: '/token'),
          ),
          type: DioExceptionType.badResponse,
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(dioErrorRefresh401);
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>(
            (e) => e.response?.statusCode == responseStatusCode401,
          )),
        );

        expect(
          authorizationInterceptors.authenticationType,
          AuthenticationType.oidc,
        );
      },
    );

    test(
      'WHEN refresh fails with 403 DioException\n'
      'THEN propagate refreshError directly\n'
      'AND OIDC state is NOT cleared',
      () async {
        const responseStatusCode403 = 403;

        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );

        final dioErrorRefresh403 = DioException(
          requestOptions: RequestOptions(path: '/token'),
          response: Response(
            statusCode: responseStatusCode403,
            requestOptions: RequestOptions(path: '/token'),
          ),
          type: DioExceptionType.badResponse,
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(dioErrorRefresh403);
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>(
            (e) => e.response?.statusCode == responseStatusCode403,
          )),
        );

        expect(
          authorizationInterceptors.authenticationType,
          AuthenticationType.oidc,
        );
      },
    );

    test(
      'WHEN refresh fails with 500 DioException\n'
      'THEN propagate refreshError directly (not stale 401)\n'
      'AND OIDC state is NOT cleared',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        final dioErrorRefresh500 = DioException(
          requestOptions: RequestOptions(path: '/token'),
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/token'),
          ),
          type: DioExceptionType.badResponse,
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(dioErrorRefresh500);
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          // must carry 500 (own response), not stale 401 → would trigger BadCredentialsException
          throwsA(predicate<DioException>(
            (e) => e.response?.statusCode == responseStatusCode500,
          )),
        );

        expect(
          authorizationInterceptors.authenticationType,
          AuthenticationType.oidc,
        );
      },
    );
  });

  // ============================================================
  // onError: refresh fails with non-DioException (outer catch)
  // ============================================================
  group('onError: refresh fails with non-DioException (outer catch)', () {
    test(
      'WHEN refresh throws ServerError\n'
      'THEN outer catch wraps it in DioException with error = ServerError',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(const ServerError());
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>(
            (e) => e.error is ServerError && e.response == null,
          )),
        );
      },
    );

    test(
      'WHEN refresh throws TemporarilyUnavailable\n'
      'THEN outer catch wraps it in DioException with error = TemporarilyUnavailable',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(const TemporarilyUnavailable());
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>(
            (e) => e.error is TemporarilyUnavailable && e.response == null,
          )),
        );
      },
    );

    test(
      'WHEN refresh throws generic non-DioException (AccessTokenInvalidException)\n'
      'THEN outer catch creates fresh DioException with NO HTTP response\n'
      'AND does NOT preserve original 401 (Fix 3 regression)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(AccessTokenInvalidException());
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>((e) {
            return e.error is AccessTokenInvalidException && e.response == null;
          })),
        );
      },
    );
  });

  // ============================================================
  // onError: skip refresh scenarios
  // ============================================================
  group('onError: skip refresh scenarios', () {
    test(
      'WHEN error is 500 (not 401)\n'
      'THEN no refresh attempt, propagate error directly',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        final dioError500 = DioException(
          error: {'message': 'Internal Server Error'},
          requestOptions: RequestOptions(path: baseUrl, method: 'POST'),
          response: Response(
            statusCode: responseStatusCode500,
            requestOptions: RequestOptions(path: baseUrl),
          ),
          type: DioExceptionType.badResponse,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode500, dioError500),
        );

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>(
            (e) => e.response?.statusCode == responseStatusCode500,
          )),
        );

        verifyNever(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        ));
      },
    );

    test(
      'WHEN authenticationType is basic and error is 401\n'
      'THEN no refresh attempt, propagate error',
      () async {
        authorizationInterceptors.setBasicAuthorization(
          UserName('alice'),
          Password('password'),
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>(
            (e) => e.response?.statusCode == responseStatusCode401,
          )),
        );
      },
    );

    test(
      'WHEN OIDC config is null and error is 401\n'
      'THEN no refresh attempt, propagate error',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: null,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>(
            (e) => e.response?.statusCode == responseStatusCode401,
          )),
        );

        verifyNever(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        ));
      },
    );

    test(
      'WHEN _refreshAttemptedKey is already set on request\n'
      'THEN skip both retry and refresh checks\n'
      'AND propagate error directly',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        // Use server.reply(401) instead of server.throws() so that Dio
        // creates the DioException from the ORIGINAL request options,
        // preserving the _refreshAttemptedKey extra.
        dioAdapter.onPost(
          baseUrl,
          (server) => server.reply(
            responseStatusCode401,
            {'error': 'Unauthorized'},
          ),
        );

        await expectLater(
          () => dio.post(
            baseUrl,
            options: Options(
              extra: {'_authInterceptorRefreshAttempted': true},
            ),
          ),
          throwsA(predicate<DioException>(
            (e) => e.response?.statusCode == responseStatusCode401,
          )),
        );

        verifyNever(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        ));
      },
    );
  });

  // ============================================================
  // onError: multiple queued requests
  // ============================================================
  group('onError: multiple queued requests', () {
    test(
      'GIVEN 2 sequential requests with expired token\n'
      'WHEN Request 1 refreshes token successfully\n'
      'THEN Request 2 uses new token directly\n'
      'AND refresh is called only once',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        // Request 1: old token → 401
        dioAdapter.onPost(
          '$baseUrl/1',
          (server) => server.throws(
            responseStatusCode401,
            makeDioError401(path: '$baseUrl/1'),
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        // Request 1 retry: new token → 200
        dioAdapter.onPost(
          '$baseUrl/1',
          (server) =>
              server.reply(responseStatusCode200, dataRequestSuccessfully),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        // Request 2: after Request 1 completes, onRequest uses new token → 200
        dioAdapter.onPost(
          '$baseUrl/2',
          (server) =>
              server.reply(responseStatusCode200, dataRequestSuccessfully),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        final response1 = await dio.post('$baseUrl/1');
        final response2 = await dio.post('$baseUrl/2');

        // Refresh called only once by Request 1
        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).called(1);

        expect(response1.statusCode, equals(HttpStatus.ok));
        expect(
          response1.requestOptions.headers[HttpHeaders.authorizationHeader],
          equals('Bearer ${OIDCFixtures.newTokenOidc.token}'),
        );

        expect(response2.statusCode, equals(HttpStatus.ok));
        expect(
          response2.requestOptions.headers[HttpHeaders.authorizationHeader],
          equals('Bearer ${OIDCFixtures.newTokenOidc.token}'),
        );
      },
    );

    test(
      'GIVEN request with expired token\n'
      'WHEN refresh fails with non-DioException\n'
      'THEN error is propagated via outer catch',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          '$baseUrl/1',
          (server) => server.throws(
            responseStatusCode401,
            makeDioError401(path: '$baseUrl/1'),
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(AccessTokenInvalidException());
        stubAccountCache();

        await expectLater(
          () => dio.post('$baseUrl/1'),
          throwsA(predicate<DioException>(
            (e) => e.error is AccessTokenInvalidException,
          )),
        );

        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).called(1);
      },
    );

    test(
      'GIVEN 2 concurrent requests with expired token\n'
      'WHEN both get 401 and enter onError queue\n'
      'THEN Request 1 refreshes token\n'
      'AND Request 2 retries with new token via validateToRetryTheRequestWithNewToken\n'
      'AND refresh is called only once',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        // Use server.reply(401) so Dio creates DioException from
        // original requestOptions (preserving auth header from onRequest)
        dioAdapter.onPost(
          '$baseUrl/1',
          (server) => server.reply(
            responseStatusCode401,
            {'error': 'Unauthorized'},
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        dioAdapter.onPost(
          '$baseUrl/2',
          (server) => server.reply(
            responseStatusCode401,
            {'error': 'Unauthorized'},
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );

        // Retry handlers: new token → 200
        dioAdapter.onPost(
          '$baseUrl/1',
          (server) =>
              server.reply(responseStatusCode200, dataRequestSuccessfully),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );
        dioAdapter.onPost(
          '$baseUrl/2',
          (server) =>
              server.reply(responseStatusCode200, dataRequestSuccessfully),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        // Fire both requests concurrently
        final future1 = dio.post('$baseUrl/1');
        final future2 = dio.post('$baseUrl/2');
        final responses = await Future.wait([future1, future2]);

        // Refresh should be called only once (by whichever enters onError first)
        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).called(1);

        expect(responses[0].statusCode, equals(HttpStatus.ok));
        expect(responses[1].statusCode, equals(HttpStatus.ok));

        expect(
          responses[0].requestOptions.headers[HttpHeaders.authorizationHeader],
          equals('Bearer ${OIDCFixtures.newTokenOidc.token}'),
        );
        expect(
          responses[1].requestOptions.headers[HttpHeaders.authorizationHeader],
          equals('Bearer ${OIDCFixtures.newTokenOidc.token}'),
        );
      },
    );

    test(
      'GIVEN 3 concurrent requests with expired token\n'
      'WHEN all get 401\n'
      'THEN only first request triggers refresh\n'
      'AND other 2 retry with new token without refreshing\n'
      'AND refresh is called exactly once',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        // All 3 requests with old token → 401
        for (final i in [1, 2, 3]) {
          dioAdapter.onPost(
            '$baseUrl/$i',
            (server) => server.reply(
              responseStatusCode401,
              {'error': 'Unauthorized'},
            ),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
            },
          );
          // Retry with new token → 200
          dioAdapter.onPost(
            '$baseUrl/$i',
            (server) =>
                server.reply(responseStatusCode200, dataRequestSuccessfully),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.newTokenOidc.token}',
            },
          );
        }

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        final responses = await Future.wait([
          dio.post('$baseUrl/1'),
          dio.post('$baseUrl/2'),
          dio.post('$baseUrl/3'),
        ]);

        // Refresh called exactly once regardless of how many requests queued
        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).called(1);

        for (final response in responses) {
          expect(response.statusCode, equals(HttpStatus.ok));
          expect(
            response.requestOptions.headers[HttpHeaders.authorizationHeader],
            equals('Bearer ${OIDCFixtures.newTokenOidc.token}'),
          );
        }
      },
    );

    test(
      'GIVEN 2 concurrent requests with expired token\n'
      'WHEN both get 401\n'
      'AND Request 1 refresh fails with 400 (state cleared)\n'
      'THEN Request 1 rejects with RefreshTokenFailedException\n'
      'AND Request 2 also fails (state cleared, no retry possible)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        // Both requests with old token → 401
        dioAdapter.onPost(
          '$baseUrl/1',
          (server) => server.reply(
            responseStatusCode401,
            {'error': 'Unauthorized'},
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        dioAdapter.onPost(
          '$baseUrl/2',
          (server) => server.reply(
            responseStatusCode401,
            {'error': 'Unauthorized'},
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(dioErrorRefresh400);
        stubAccountCache();

        // Fire both requests concurrently
        final future1 = dio.post('$baseUrl/1');
        final future2 = dio.post('$baseUrl/2');

        // Request 1: refresh fails with 400 → RefreshTokenFailedException
        DioException? error1;
        DioException? error2;
        try {
          await future1;
        } on DioException catch (e) {
          error1 = e;
        }
        try {
          await future2;
        } on DioException catch (e) {
          error2 = e;
        }

        expect(error1, isNotNull);
        expect(error1?.error, isA<RefreshTokenFailedException>());
        expect(error1?.response?.statusCode, 400);

        // Request 2: state was cleared by Request 1, so no refresh/retry
        // possible → propagates original 401
        expect(error2, isNotNull);

        // State should be cleared
        expect(
          authorizationInterceptors.authenticationType,
          AuthenticationType.none,
        );
      },
    );

    test(
      'GIVEN sequential requests after state cleared by 400\n'
      'WHEN first request refresh fails with 400 and clears state\n'
      'AND second request is made afterwards\n'
      'THEN second request fails immediately (no OIDC, no refresh)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        // Request 1: old token → 401
        dioAdapter.onPost(
          '$baseUrl/1',
          (server) => server.throws(
            responseStatusCode401,
            makeDioError401(path: '$baseUrl/1'),
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(dioErrorRefresh400);
        stubAccountCache();

        // Request 1 fails with RefreshTokenFailedException
        await expectLater(
          () => dio.post('$baseUrl/1'),
          throwsA(predicate<DioException>(
            (e) => e.error is RefreshTokenFailedException,
          )),
        );

        // State is now cleared
        expect(
          authorizationInterceptors.authenticationType,
          AuthenticationType.none,
        );

        // Request 2: no auth header added (type is none), server returns 401
        dioAdapter.onPost(
          '$baseUrl/2',
          (server) => server.reply(
            responseStatusCode401,
            {'error': 'Unauthorized'},
          ),
        );

        // Request 2 fails — no OIDC config, no refresh possible
        await expectLater(
          () => dio.post('$baseUrl/2'),
          throwsA(predicate<DioException>(
            (e) => e.response?.statusCode == responseStatusCode401,
          )),
        );

        // Refresh should NOT be called again (state cleared)
        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).called(1); // only the first call
      },
    );

    test(
      'GIVEN 2 concurrent requests with expired token\n'
      'WHEN both get 401\n'
      'AND refresh returns duplicate token each time\n'
      'THEN both requests propagate 401 (token duplicated)\n'
      'AND no infinite loop occurs',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        // Both requests → 401
        dioAdapter.onPost(
          '$baseUrl/1',
          (server) => server.reply(
            responseStatusCode401,
            {'error': 'Unauthorized'},
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        dioAdapter.onPost(
          '$baseUrl/2',
          (server) => server.reply(
            responseStatusCode401,
            {'error': 'Unauthorized'},
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );

        var refreshCallCount = 0;
        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async {
          refreshCallCount++;
          return OIDCFixtures.tokenOidcExpiredTime; // same token → duplicate
        });
        stubAccountCache();

        final future1 = dio.post('$baseUrl/1');
        final future2 = dio.post('$baseUrl/2');

        DioException? error1;
        DioException? error2;
        try {
          await future1;
        } on DioException catch (e) {
          error1 = e;
        }
        try {
          await future2;
        } on DioException catch (e) {
          error2 = e;
        }

        // Both should fail with 401
        expect(error1, isNotNull);
        expect(error1!.response?.statusCode, responseStatusCode401);

        expect(error2, isNotNull);
        expect(error2!.response?.statusCode, responseStatusCode401);

        // Both requests independently attempt refresh (duplicate didn't
        // update _token, so second request can't detect the first's attempt).
        // Key assertion: no infinite loop — each request tries once and stops.
        expect(refreshCallCount, 2);
      },
    );
  });

  // ============================================================
  // onError: retry fails (separate Dio error handling)
  // ============================================================
  group('onError: retry fails (separate Dio error handling)', () {
    test(
      'WHEN refresh succeeds but retry with new token gets 401\n'
      'THEN error is propagated via retry catch block\n'
      'AND no deadlock occurs',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        // Old token → 401
        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        // Retry with new token → also 401
        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(
            responseStatusCode401,
            makeDioError401(),
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(isA<DioException>()),
        );

        // Refresh was called once
        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).called(1);
      },
    );

    test(
      'WHEN refresh succeeds but retry gets 500\n'
      'THEN propagated error carries 500 (not stale 401)\n'
      'AND OIDC state is preserved',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        final dioError500 = DioException(
          error: {'message': 'Internal Server Error'},
          requestOptions: RequestOptions(path: baseUrl, method: 'POST'),
          response: Response(
            statusCode: responseStatusCode500,
            requestOptions: RequestOptions(path: baseUrl),
          ),
          type: DioExceptionType.badResponse,
        );

        // Old token → 401
        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        // Retry with new token → 500
        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode500, dioError500),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          // must carry 500, not stale 401 → would trigger BadCredentialsException
          throwsA(predicate<DioException>(
            (e) => e.response?.statusCode == responseStatusCode500,
          )),
        );

        // OIDC state should NOT be cleared (only 400 clears state)
        expect(
          authorizationInterceptors.authenticationType,
          AuthenticationType.oidc,
        );
      },
    );

    test(
      'GIVEN 2 concurrent requests\n'
      'WHEN Request 1 refreshes and retries successfully\n'
      'AND Request 2 retries with new token but gets 500\n'
      'THEN Request 1 succeeds\n'
      'AND Request 2 error is propagated',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        final dioError500 = DioException(
          error: {'message': 'Internal Server Error'},
          requestOptions: RequestOptions(path: '$baseUrl/2', method: 'POST'),
          response: Response(
            statusCode: responseStatusCode500,
            requestOptions: RequestOptions(path: '$baseUrl/2'),
          ),
          type: DioExceptionType.badResponse,
        );

        // Request 1: old token → 401
        dioAdapter.onPost(
          '$baseUrl/1',
          (server) => server.reply(
            responseStatusCode401,
            {'error': 'Unauthorized'},
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        // Request 1 retry: new token → 200
        dioAdapter.onPost(
          '$baseUrl/1',
          (server) =>
              server.reply(responseStatusCode200, dataRequestSuccessfully),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        // Request 2: old token → 401
        dioAdapter.onPost(
          '$baseUrl/2',
          (server) => server.reply(
            responseStatusCode401,
            {'error': 'Unauthorized'},
          ),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        // Request 2 retry: new token → 500
        dioAdapter.onPost(
          '$baseUrl/2',
          (server) => server.throws(responseStatusCode500, dioError500),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        final future1 = dio.post('$baseUrl/1');
        final future2 = dio.post('$baseUrl/2');

        final response1 = await future1;
        expect(response1.statusCode, responseStatusCode200);

        await expectLater(
          () => future2,
          throwsA(isA<DioException>()),
        );
      },
    );
  });

  // ============================================================
  // onError: token duplicate prevents infinite loop
  // ============================================================
  group('onError: token duplicate prevents infinite loop', () {
    test(
      'WHEN refresh returns same token as current\n'
      'THEN "Token duplicated" detected\n'
      'AND original error propagated\n'
      'AND refresh called exactly once',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcNotExpiredYet,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        var refreshCallCount = 0;

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcNotExpiredYet.refreshToken,
        )).thenAnswer((_) async {
          refreshCallCount++;
          return OIDCFixtures.tokenOidcNotExpiredYet; // same token → duplicate
        });
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>(
            (e) => e.response?.statusCode == responseStatusCode401,
          )),
        );

        expect(refreshCallCount, 1);
      },
    );
  });

  group('Bug 1 — refresh network timeout preserves original 401 response (regression)', () {
    final refreshTimeoutError = DioException(
      requestOptions: RequestOptions(path: '/token'),
      type: DioExceptionType.connectionTimeout,
    );

    test(
      'WHEN 401 with expired token\n'
      'AND refresh call times out (connectionTimeout, response=null)\n'
      'THEN propagated error carries NO HTTP response\n'
      '(BUG: err.copyWith preserves original 401 response → RemoteExceptionThrower → logout)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(refreshTimeoutError);

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>((e) => e.response == null)),
        );
      },
    );

    test(
      'WHEN server-side 401 (token not locally expired)\n'
      'AND refresh call times out\n'
      'THEN propagated error carries NO HTTP response',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcNotExpiredYet,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcNotExpiredYet.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcNotExpiredYet.refreshToken,
        )).thenThrow(refreshTimeoutError);

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>((e) {
            return e.response == null;
          })),
        );
      },
    );

  });

  group('Bug 1 — retry network timeout preserves original 401 response (regression)', () {
    test(
      'WHEN 401 with expired token\n'
      'AND refresh succeeds\n'
      'AND retry call times out (connectionTimeout, response=null)\n'
      'THEN propagated error carries NO HTTP response\n'
      '(BUG: err.copyWith preserves original 401 response → logout)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );

        final retryTimeoutError = DioException(
          requestOptions: RequestOptions(path: baseUrl),
          type: DioExceptionType.connectionTimeout,
        );
        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(0, retryTimeoutError),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>((e) => e.response == null)),
        );
      },
    );

  });

  group(
    'Bug 1 — FlutterAppAuthPlatformException from OIDC refresh '
    'does not preserve original 401 (outer catch)',
    () {
      // _appAuth.token() OIDC no-internet: native SDK throws
      // FlutterAppAuthPlatformException(error: null) — transport failure.
      // details==null path rethrows raw PlatformException instead.
      // Both handled identically by outer catch.
      final platformNetworkException = FlutterAppAuthPlatformException(
        code: 'network_error',
        message: 'Failed to connect to token endpoint',
        platformErrorDetails: FlutterAppAuthPlatformErrorDetails(
          error: null, // null = pure transport failure, not an OAuth error
        ),
      );

      test(
        'WHEN 401 with expired token\n'
        'AND refresh throws FlutterAppAuthPlatformException (no internet)\n'
        'THEN propagated DioException has NO HTTP response\n'
        'AND error is FlutterAppAuthPlatformException\n'
        '(BUG: outer catch err.copyWith preserved original 401 → BadCredentialsException → logout)',
        () async {
          authorizationInterceptors.setTokenAndAuthorityOidc(
            newToken: OIDCFixtures.tokenOidcExpiredTime,
            newConfig: OIDCFixtures.oidcConfiguration,
          );

          dioAdapter.onPost(
            baseUrl,
            (server) =>
                server.throws(responseStatusCode401, makeDioError401()),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
            },
          );

          when(authenticationClient.refreshingTokensOIDC(
            OIDCFixtures.oidcConfiguration.clientId,
            OIDCFixtures.oidcConfiguration.redirectUrl,
            OIDCFixtures.oidcConfiguration.discoveryUrl,
            OIDCFixtures.oidcConfiguration.scopes,
            OIDCFixtures.tokenOidcExpiredTime.refreshToken,
          )).thenThrow(platformNetworkException);

          await expectLater(
            () => dio.post(baseUrl),
            throwsA(predicate<DioException>((e) {
              return e.response == null &&
                  e.error is FlutterAppAuthPlatformException;
            })),
          );
        },
      );

      test(
        'WHEN server-side 401 (token not locally expired)\n'
        'AND refresh throws FlutterAppAuthPlatformException (no internet)\n'
        'THEN propagated DioException has NO HTTP response',
        () async {
          authorizationInterceptors.setTokenAndAuthorityOidc(
            newToken: OIDCFixtures.tokenOidcNotExpiredYet,
            newConfig: OIDCFixtures.oidcConfiguration,
          );

          dioAdapter.onPost(
            baseUrl,
            (server) =>
                server.throws(responseStatusCode401, makeDioError401()),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.tokenOidcNotExpiredYet.token}',
            },
          );

          when(authenticationClient.refreshingTokensOIDC(
            OIDCFixtures.oidcConfiguration.clientId,
            OIDCFixtures.oidcConfiguration.redirectUrl,
            OIDCFixtures.oidcConfiguration.discoveryUrl,
            OIDCFixtures.oidcConfiguration.scopes,
            OIDCFixtures.tokenOidcNotExpiredYet.refreshToken,
          )).thenThrow(platformNetworkException);

          await expectLater(
            () => dio.post(baseUrl),
            throwsA(predicate<DioException>((e) {
              return e.response == null &&
                  e.error is FlutterAppAuthPlatformException;
            })),
          );
        },
      );

      test(
        'WHEN refresh throws raw PlatformException (invokeMethod details==null path)\n'
        'THEN propagated DioException has NO HTTP response',
        () async {
          authorizationInterceptors.setTokenAndAuthorityOidc(
            newToken: OIDCFixtures.tokenOidcExpiredTime,
            newConfig: OIDCFixtures.oidcConfiguration,
          );

          dioAdapter.onPost(
            baseUrl,
            (server) =>
                server.throws(responseStatusCode401, makeDioError401()),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
            },
          );

          // e.details==null → invokeMethod rethrows PlatformException → handleException passes through → outer catch → fresh DioException(response: null)
          when(authenticationClient.refreshingTokensOIDC(
            OIDCFixtures.oidcConfiguration.clientId,
            OIDCFixtures.oidcConfiguration.redirectUrl,
            OIDCFixtures.oidcConfiguration.discoveryUrl,
            OIDCFixtures.oidcConfiguration.scopes,
            OIDCFixtures.tokenOidcExpiredTime.refreshToken,
          )).thenThrow(PlatformException(
            code: 'network_error',
            message: 'Failed to connect to token endpoint',
          ));

          await expectLater(
            () => dio.post(baseUrl),
            throwsA(predicate<DioException>((e) {
              return e.response == null && e.error is PlatformException;
            })),
          );
        },
      );

      test(
        'WHEN refresh throws OAuthAuthorizationError (e.g. invalid_grant)\n'
        'THEN propagated DioException still has NO HTTP response',
        () async {
          authorizationInterceptors.setTokenAndAuthorityOidc(
            newToken: OIDCFixtures.tokenOidcExpiredTime,
            newConfig: OIDCFixtures.oidcConfiguration,
          );

          dioAdapter.onPost(
            baseUrl,
            (server) =>
                server.throws(responseStatusCode401, makeDioError401()),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
            },
          );

          // FlutterAppAuthPlatformException(error:'invalid_grant') → handleException() → OAuthAuthorizationError
          when(authenticationClient.refreshingTokensOIDC(
            OIDCFixtures.oidcConfiguration.clientId,
            OIDCFixtures.oidcConfiguration.redirectUrl,
            OIDCFixtures.oidcConfiguration.discoveryUrl,
            OIDCFixtures.oidcConfiguration.scopes,
            OIDCFixtures.tokenOidcExpiredTime.refreshToken,
          )).thenThrow(const OAuthAuthorizationError(
            error: 'invalid_grant',
            errorDescription: 'The refresh token has been revoked',
          ));

          await expectLater(
            () => dio.post(baseUrl),
            throwsA(predicate<DioException>((e) {
              return e.response == null &&
                  e.error is OAuthAuthorizationError;
            })),
          );
        },
      );

    },
  );

  group('onError: multiple requests all fail 401', () {
    test(
      'GIVEN 4 concurrent requests with expired token\n'
      'WHEN all get 401\n'
      'THEN only first request triggers refresh\n'
      'AND other 3 retry with new token without refreshing\n'
      'AND refresh is called exactly once',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        for (final i in [1, 2, 3, 4]) {
          dioAdapter.onPost(
            '$baseUrl/$i',
            (server) => server.reply(
              responseStatusCode401,
              {'error': 'Unauthorized'},
            ),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
            },
          );
          dioAdapter.onPost(
            '$baseUrl/$i',
            (server) =>
                server.reply(responseStatusCode200, dataRequestSuccessfully),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.newTokenOidc.token}',
            },
          );
        }

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        final responses = await Future.wait([
          dio.post('$baseUrl/1'),
          dio.post('$baseUrl/2'),
          dio.post('$baseUrl/3'),
          dio.post('$baseUrl/4'),
        ]);

        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).called(1);

        for (final response in responses) {
          expect(response.statusCode, equals(HttpStatus.ok));
          expect(
            response.requestOptions.headers[HttpHeaders.authorizationHeader],
            equals('Bearer ${OIDCFixtures.newTokenOidc.token}'),
          );
        }
      },
    );

    test(
      'GIVEN 3 concurrent requests with expired token\n'
      'WHEN all get 401\n'
      'AND refresh fails with connectionTimeout (no HTTP response)\n'
      'THEN all 3 requests fail with response=null\n'
      'AND none carry the original 401 response (no spurious logout)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        for (final i in [1, 2, 3]) {
          dioAdapter.onPost(
            '$baseUrl/$i',
            (server) => server.reply(
              responseStatusCode401,
              {'error': 'Unauthorized'},
            ),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
            },
          );
        }

        final refreshTimeoutError = DioException(
          requestOptions: RequestOptions(path: '/token'),
          type: DioExceptionType.connectionTimeout,
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(refreshTimeoutError);
        stubAccountCache();

        final futures = [
          dio.post('$baseUrl/1'),
          dio.post('$baseUrl/2'),
          dio.post('$baseUrl/3'),
        ];

        final errors = <DioException>[];
        for (final future in futures) {
          try {
            await future;
          } on DioException catch (e) {
            errors.add(e);
          }
        }

        expect(errors.length, 3);
        for (final error in errors) {
          expect(error.response, isNull,
              reason: 'Must not carry original 401 response');
        }
      },
    );

    test(
      'GIVEN 3 concurrent requests with expired token\n'
      'WHEN all get 401\n'
      'AND refresh fails with PlatformException (mobile: no internet)\n'
      'THEN all 3 requests fail with response=null\n'
      'AND none carry the original 401 response (no spurious logout)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        for (final i in [1, 2, 3]) {
          dioAdapter.onPost(
            '$baseUrl/$i',
            (server) => server.reply(
              responseStatusCode401,
              {'error': 'Unauthorized'},
            ),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
            },
          );
        }

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(PlatformException(
          code: 'network_error',
          message: 'Failed to connect to token endpoint',
        ));
        stubAccountCache();

        final futures = [
          dio.post('$baseUrl/1'),
          dio.post('$baseUrl/2'),
          dio.post('$baseUrl/3'),
        ];

        final errors = <DioException>[];
        for (final future in futures) {
          try {
            await future;
          } on DioException catch (e) {
            errors.add(e);
          }
        }

        expect(errors.length, 3);
        for (final error in errors) {
          expect(error.response, isNull,
              reason: 'Must not carry original 401 response');
          expect(error.error, isA<PlatformException>());
        }
      },
    );

    test(
      'GIVEN 3 concurrent requests with expired token\n'
      'WHEN all get 401\n'
      'AND refresh fails with 400 (invalid grant)\n'
      'THEN all 3 requests fail\n'
      'AND auth state is cleared (none)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        for (final i in [1, 2, 3]) {
          dioAdapter.onPost(
            '$baseUrl/$i',
            (server) => server.reply(
              responseStatusCode401,
              {'error': 'Unauthorized'},
            ),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
            },
          );
        }

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(dioErrorRefresh400);
        stubAccountCache();

        final futures = [
          dio.post('$baseUrl/1'),
          dio.post('$baseUrl/2'),
          dio.post('$baseUrl/3'),
        ];

        final errors = <DioException>[];
        for (final future in futures) {
          try {
            await future;
          } on DioException catch (e) {
            errors.add(e);
          }
        }

        expect(errors, isNotEmpty);

        expect(
          authorizationInterceptors.authenticationType,
          AuthenticationType.none,
        );
      },
    );

    test(
      'GIVEN 3 concurrent requests: 2 fail 401 + 1 fails 500\n'
      'WHEN processed concurrently\n'
      'THEN 401 requests attempt refresh and retry with new token\n'
      'AND 500 request propagates directly without touching refresh logic',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        final dioError500 = DioException(
          requestOptions: RequestOptions(path: '$baseUrl/500', method: 'POST'),
          response: Response(
            statusCode: responseStatusCode500,
            requestOptions: RequestOptions(path: '$baseUrl/500'),
          ),
          type: DioExceptionType.badResponse,
        );

        // 2 requests get 401 with expired token
        for (final i in [1, 2]) {
          dioAdapter.onPost(
            '$baseUrl/$i',
            (server) => server.reply(
              responseStatusCode401,
              {'error': 'Unauthorized'},
            ),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
            },
          );
          dioAdapter.onPost(
            '$baseUrl/$i',
            (server) =>
                server.reply(responseStatusCode200, dataRequestSuccessfully),
            headers: {
              HttpHeaders.authorizationHeader:
                  'Bearer ${OIDCFixtures.newTokenOidc.token}',
            },
          );
        }

        // 1 request gets 500 (not related to auth)
        dioAdapter.onPost(
          '$baseUrl/500',
          (server) => server.throws(responseStatusCode500, dioError500),
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        final future1 = dio.post('$baseUrl/1');
        final future2 = dio.post('$baseUrl/2');
        final future500 = dio.post('$baseUrl/500');

        final response1 = await future1;
        final response2 = await future2;
        DioException? error500;
        try {
          await future500;
        } on DioException catch (e) {
          error500 = e;
        }

        expect(response1.statusCode, responseStatusCode200);
        expect(response2.statusCode, responseStatusCode200);

        expect(error500, isNotNull);
        expect(error500?.response?.statusCode, responseStatusCode500);

        // refresh called at most once (concurrent 401 requests share one refresh)
        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).called(1);
      },
    );

    test(
      'GIVEN 3 concurrent requests with basic auth (not OIDC)\n'
      'WHEN all get 401\n'
      'THEN no refresh attempted\n'
      'AND all 3 fail with 401',
      () async {
        authorizationInterceptors.setBasicAuthorization(
          UserName('alice'),
          Password('password'),
        );

        for (final i in [1, 2, 3]) {
          dioAdapter.onPost(
            '$baseUrl/$i',
            (server) => server.reply(
              responseStatusCode401,
              {'error': 'Unauthorized'},
            ),
          );
        }

        final futures = [
          dio.post('$baseUrl/1'),
          dio.post('$baseUrl/2'),
          dio.post('$baseUrl/3'),
        ];

        final errors = <DioException>[];
        for (final future in futures) {
          try {
            await future;
          } on DioException catch (e) {
            errors.add(e);
          }
        }

        expect(errors.length, 3);
        for (final error in errors) {
          expect(error.response?.statusCode, responseStatusCode401);
        }

        verifyNever(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        ));
      },
    );
  });

  // ============================================================
  // onError: refresh side-effect failures
  // ============================================================
  group('onError: refresh side-effect failures', () {
    test(
      'WHEN refresh succeeds but _updateCurrentAccount throws (cache failure)\n'
      'THEN outer catch wraps cache error in fresh DioException\n'
      'AND propagated error has NO HTTP response (no stale 401 → no logout)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        when(accountCacheManager.getCurrentAccount())
            .thenAnswer((_) async => AccountFixtures.aliceAccount);
        when(accountCacheManager.deleteCurrentAccount(AccountFixtures.aliceAccount.id))
            .thenThrow(Exception('Cache write failure'));

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>((e) {
            return e.response == null && e.error is Exception;
          })),
        );
      },
    );

    test(
      'WHEN platform is iOS\n'
      'AND refresh succeeds but Keychain save throws\n'
      'THEN outer catch wraps keychain error in fresh DioException\n'
      'AND propagated error has NO HTTP response',
      () async {
        debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
        addTearDown(() => debugDefaultTargetPlatformOverride = null);

        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        // iOS: keychain returns null → server refresh path
        when(iosSharingManager.getKeychainSharingSession(AccountFixtures.aliceAccountId))
            .thenAnswer((_) async => null);
        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();
        final expectedPersonalAccount = PersonalAccount(
          OIDCFixtures.newTokenOidc.tokenIdHash,
          AuthenticationType.oidc,
          isSelected: true,
          accountId: AccountFixtures.aliceAccountId,
          apiUrl: AccountFixtures.aliceAccount.apiUrl,
          userName: AccountFixtures.aliceAccount.userName,
        );
        when(iosSharingManager.saveKeyChainSharingSession(expectedPersonalAccount))
            .thenThrow(Exception('Keychain access denied'));

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>((e) {
            return e.response == null && e.error is Exception;
          })),
        );
      },
    );
  });

  // ============================================================
  // onError: upload retry with attachment extras
  // ============================================================
  group('onError: upload retry with attachment extras', () {
    test(
      'WHEN 401 on upload request with uploadAttachmentExtraKey + filePath\n'
      'AND refresh succeeds\n'
      'THEN upload-specific retry path is taken (uses retryDio.request, not fetch)\n'
      'AND retry succeeds with 200',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        // filePath='' triggers the streamData fallback inside _getDataUploadRequest.
        // streamData is null → retryDio.request is called with data=null, still
        // exercising the upload branch (vs fetch branch).
        final uploadExtras = <String, dynamic>{
          'upload-attachment': <String, dynamic>{
            'path': '',
            'streamData': null,
          },
        };

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        dioAdapter.onPost(
          baseUrl,
          (server) =>
              server.reply(responseStatusCode200, dataRequestSuccessfully),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        final response = await dio.post(
          baseUrl,
          options: Options(extra: uploadExtras),
        );

        expect(response.statusCode, responseStatusCode200);
        expect(response.data, dataRequestSuccessfully);
      },
    );

    test(
      'WHEN upload extras has invalid map shape\n'
      'AND refresh succeeds\n'
      'THEN _getDataUploadRequest returns null but retry still completes\n'
      '(defensive: malformed extras must not crash the interceptor)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        final malformedExtras = <String, dynamic>{
          'upload-attachment': 'not a map',
        };

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        dioAdapter.onPost(
          baseUrl,
          (server) =>
              server.reply(responseStatusCode200, dataRequestSuccessfully),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        final response = await dio.post(
          baseUrl,
          options: Options(extra: malformedExtras),
        );

        expect(response.statusCode, responseStatusCode200);
      },
    );
  });

  // ============================================================
  // onError: iOS keychain refresh path
  // ============================================================
  group('onError: iOS keychain refresh path', () {
    setUp(() => debugDefaultTargetPlatformOverride = TargetPlatform.iOS);
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test(
      'WHEN platform is iOS\n'
      'AND keychain contains a newer non-expired token (rotated by another app process)\n'
      'THEN use keychain token without calling refreshingTokensOIDC\n'
      'AND retry succeeds with 200',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        dioAdapter.onPost(
          baseUrl,
          (server) =>
              server.reply(responseStatusCode200, dataRequestSuccessfully),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        final keychainSession = KeychainSharingSession(
          accountId: AccountFixtures.aliceAccountId,
          userName: AccountFixtures.aliceAccount.userName!,
          authenticationType: AuthenticationType.oidc,
          apiUrl: AccountFixtures.aliceAccount.apiUrl!,
          tokenOIDC: OIDCFixtures.newTokenOidc,
        );
        when(iosSharingManager
                .getKeychainSharingSession(AccountFixtures.aliceAccountId))
            .thenAnswer((_) async => keychainSession);

        final expectedPersonalAccount = PersonalAccount(
          OIDCFixtures.newTokenOidc.tokenIdHash,
          AuthenticationType.oidc,
          isSelected: true,
          accountId: AccountFixtures.aliceAccountId,
          apiUrl: AccountFixtures.aliceAccount.apiUrl,
          userName: AccountFixtures.aliceAccount.userName,
        );
        when(iosSharingManager
                .saveKeyChainSharingSession(expectedPersonalAccount))
            .thenAnswer((_) async {});
        stubAccountCache();

        final response = await dio.post(baseUrl);

        expect(response.statusCode, responseStatusCode200);
        verifyNever(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        ));
      },
    );

    test(
      'WHEN platform is iOS\n'
      'AND keychain returns expired tokenOIDC\n'
      'THEN fallback to server refreshingTokensOIDC\n'
      'AND retry succeeds with 200',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        dioAdapter.onPost(
          baseUrl,
          (server) =>
              server.reply(responseStatusCode200, dataRequestSuccessfully),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        final expiredKeychainToken = TokenOIDC(
          'expired_keychain_token',
          TokenId('expired_keychain_token'),
          'older_refresh',
          expiredTime: DateTime.now().subtract(const Duration(days: 2)),
        );
        final keychainSession = KeychainSharingSession(
          accountId: AccountFixtures.aliceAccountId,
          userName: AccountFixtures.aliceAccount.userName!,
          authenticationType: AuthenticationType.oidc,
          apiUrl: AccountFixtures.aliceAccount.apiUrl!,
          tokenOIDC: expiredKeychainToken,
        );
        when(iosSharingManager
                .getKeychainSharingSession(AccountFixtures.aliceAccountId))
            .thenAnswer((_) async => keychainSession);

        final expectedPersonalAccount = PersonalAccount(
          OIDCFixtures.newTokenOidc.tokenIdHash,
          AuthenticationType.oidc,
          isSelected: true,
          accountId: AccountFixtures.aliceAccountId,
          apiUrl: AccountFixtures.aliceAccount.apiUrl,
          userName: AccountFixtures.aliceAccount.userName,
        );
        when(iosSharingManager
                .saveKeyChainSharingSession(expectedPersonalAccount))
            .thenAnswer((_) async {});

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        final response = await dio.post(baseUrl);

        expect(response.statusCode, responseStatusCode200);
        verify(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).called(1);
      },
    );
  });

  // ============================================================
  // onError: WEB refresh failures
  // Server rejection (got a response: ArgumentError / AccessTokenInvalid /
  // Dio retry with response) → preserve original 401 → logout.
  // Network/transport failure (no response) → keep session (carve-out),
  // so a flaky connection does NOT log the web user out.
  // ============================================================
  group('onError: web refresh failure handling', () {
    setUp(() => PlatformInfo.isTestingForWeb = true);
    tearDown(() => PlatformInfo.isTestingForWeb = false);

    test(
      'WHEN refresh throws ArgumentError (flutter_appauth_web non-200, e.g. 400)\n'
      'THEN original 401 response is preserved (→ BadCredentialsException → logout)\n'
      'AND error carries the ArgumentError',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(ArgumentError(
          'Failed to get token: [error: token_failed, description: invalid_grant]',
        ));
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>((e) {
            return e.response?.statusCode == responseStatusCode401 &&
                e.error is ArgumentError;
          })),
        );
      },
    );

    test(
      'WHEN refresh throws AccessTokenInvalidException\n'
      'THEN original 401 response is preserved (→ logout)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(AccessTokenInvalidException());
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>((e) {
            return e.response?.statusCode == responseStatusCode401 &&
                e.error is AccessTokenInvalidException;
          })),
        );
      },
    );

    for (final transientError in const <OAuthAuthorizationError>[
      ServerError(),
      TemporarilyUnavailable(),
    ]) {
      test(
        'WHEN refresh throws ${transientError.runtimeType}\n'
        'THEN error is propagated WITHOUT an HTTP response (legacy carve-out)',
        () async {
          authorizationInterceptors.setTokenAndAuthorityOidc(
            newToken: OIDCFixtures.tokenOidcExpiredTime,
            newConfig: OIDCFixtures.oidcConfiguration,
          );

          dioAdapter.onPost(
            baseUrl,
            (server) => server.throws(responseStatusCode401, makeDioError401()),
          );

          when(authenticationClient.refreshingTokensOIDC(
            OIDCFixtures.oidcConfiguration.clientId,
            OIDCFixtures.oidcConfiguration.redirectUrl,
            OIDCFixtures.oidcConfiguration.discoveryUrl,
            OIDCFixtures.oidcConfiguration.scopes,
            OIDCFixtures.tokenOidcExpiredTime.refreshToken,
          )).thenThrow(transientError);
          stubAccountCache();

          await expectLater(
            () => dio.post(baseUrl),
            throwsA(predicate<DioException>((e) {
              return e.response == null &&
                  e.error.runtimeType == transientError.runtimeType;
            })),
          );
        },
      );
    }

    test(
      'WHEN refresh succeeds but retry with new token fails\n'
      'THEN original 401 response is preserved (→ logout)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        // Old token → 401
        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        // Retry with new token → also 401
        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>((e) {
            // Original 401 preserved; the retry error is carried as `.error`.
            return e.response?.statusCode == responseStatusCode401 &&
                e.error is DioException;
          })),
        );
      },
    );

    test(
      'WHEN refresh fails with a network DioException (no response) on web\n'
      'THEN session is KEPT — propagated error has NO HTTP response (no logout)\n'
      'AND OIDC state is NOT cleared (carve-out vs bad network)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        final refreshNetworkError = DioException(
          requestOptions: RequestOptions(path: '/token'),
          type: DioExceptionType.connectionError,
        );
        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(refreshNetworkError);
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>((e) => e.response == null)),
        );

        expect(
          authorizationInterceptors.authenticationType,
          AuthenticationType.oidc,
        );
      },
    );

    test(
      'WHEN refresh fails with a non-Dio transport error (e.g. ClientException) on web\n'
      'THEN session is KEPT — propagated error has NO HTTP response (no logout)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
        );

        // Simulates package:http throwing on a browser network drop (no
        // server response was ever received).
        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenThrow(Exception('XMLHttpRequest error'));
        stubAccountCache();

        await expectLater(
          () => dio.post(baseUrl),
          throwsA(predicate<DioException>((e) {
            return e.response == null && e.error is Exception;
          })),
        );

        expect(
          authorizationInterceptors.authenticationType,
          AuthenticationType.oidc,
        );
      },
    );
  });

  // ============================================================
  // onError: WEB refresh SUCCESS path (platform split must not disturb it)
  // ============================================================
  group('onError: web refresh success path', () {
    setUp(() => PlatformInfo.isTestingForWeb = true);
    tearDown(() => PlatformInfo.isTestingForWeb = false);

    test(
      'WHEN 401 with expired token on web\n'
      'AND refresh returns a new token\n'
      'THEN retry succeeds with 200 (success flow unaffected by platform split)',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration,
        );

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, makeDioError401()),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}',
          },
        );
        dioAdapter.onPost(
          baseUrl,
          (server) =>
              server.reply(responseStatusCode200, dataRequestSuccessfully),
          headers: {
            HttpHeaders.authorizationHeader:
                'Bearer ${OIDCFixtures.newTokenOidc.token}',
          },
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken,
        )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);
        stubAccountCache();

        final response = await dio.post(baseUrl);

        expect(response.statusCode, responseStatusCode200);
        expect(response.data, dataRequestSuccessfully);
        // Session preserved on a successful refresh.
        expect(
          authorizationInterceptors.authenticationType,
          AuthenticationType.oidc,
        );
      },
    );
  });

  tearDown(() {
    reset(authenticationClient);
    reset(tokenOidcCacheManager);
    reset(accountCacheManager);
    reset(iosSharingManager);

    authorizationInterceptors.clear();
    dioAdapter.reset();
    dioAdapter.close();
    dio.close();
  });
}
