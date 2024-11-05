
import 'dart:io';

import 'package:core/data/constants/constant.dart';
import 'package:core/data/network/dio_client.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';
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

  const baseUrl = 'http://domain.com/jmap';
  const responseStatusCode401 = 401;
  const responseStatusCode500 = 500;
  const responseStatusCode200 = 200;

  final dioError401 = DioError(
    error: {'message': 'Token Expired'},
    requestOptions: RequestOptions(path: baseUrl, method: 'POST'),
    response: Response(
      statusCode: responseStatusCode401,
      requestOptions: RequestOptions(path: baseUrl)
    ),
    type: DioErrorType.badResponse,
  );

  final dataRequestSuccessfully = {'message': 'Request successfully!'};

  setUp(() {
    final headers = <String, dynamic>{
      HttpHeaders.acceptHeader: DioClient.jmapHeader,
      HttpHeaders.contentTypeHeader: Constant.contentTypeHeaderDefault
    };
    final baseOption = BaseOptions(headers: headers);
    dio = Dio(baseOption)
      ..options.baseUrl = baseUrl;

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

    dotenv.testLoad(mergeWith: {
      'PLATFORM': 'other'
    });
  });

  group('AuthorizationInterceptor test', () {

    group("validateToRefreshToken method test", () {
      test('validateToRefreshToken should return true when conditions are met', () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration);

        final result = authorizationInterceptors.validateToRefreshToken(
          responseStatusCode: responseStatusCode401,
          tokenOIDC: OIDCFixtures.tokenOidcExpiredTime,
        );

        expect(result, true);
      });

      test('validateToRefreshToken should return false when condition `responseStatusCode == 500`', () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration);

        final result = authorizationInterceptors.validateToRefreshToken(
          responseStatusCode: responseStatusCode500,
          tokenOIDC: OIDCFixtures.tokenOidcExpiredTime,
        );

        expect(result, false);
      });

      test('validateToRefreshToken should return false when condition `OidcConfiguration is null`', () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: null);

        final result = authorizationInterceptors.validateToRefreshToken(
          responseStatusCode: responseStatusCode401,
          tokenOIDC: OIDCFixtures.tokenOidcExpiredTime,
        );

        expect(result, false);
      });

      test('validateToRefreshToken should return false when condition `token is empty`', () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTimeAndTokenEmpty,
          newConfig: OIDCFixtures.oidcConfiguration);

        final result = authorizationInterceptors.validateToRefreshToken(
          responseStatusCode: responseStatusCode401,
          tokenOIDC: OIDCFixtures.tokenOidcExpiredTimeAndTokenEmpty,
        );

        expect(result, false);
      });

      test('validateToRefreshToken should return false when condition `refreshToken is empty`', () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTimeAndRefreshTokenEmpty,
          newConfig: OIDCFixtures.oidcConfiguration);

        final result = authorizationInterceptors.validateToRefreshToken(
          responseStatusCode: responseStatusCode401,
          tokenOIDC: OIDCFixtures.tokenOidcExpiredTimeAndRefreshTokenEmpty,
        );

        expect(result, false);
      });

      test('validateToRefreshToken should return false when condition `Time not expired`', () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.newTokenOidc,
          newConfig: OIDCFixtures.oidcConfiguration);

        final result = authorizationInterceptors.validateToRefreshToken(
          responseStatusCode: responseStatusCode401,
          tokenOIDC: OIDCFixtures.newTokenOidc,
        );

        expect(result, false);
      });
    });

    group('QueuedInterceptorsWrapper test', () {
      test(
        'WHEN make a request with `tokenOidcExpiredTime`\n'
        'AND returns error `dioError401`\n'
        'THEN refresh token successfully received `newTokenOidc`\n'
        'AND re-execute request with `newTokenOidc`\n'
        'THEN response data SHOULD return `dataRequestSuccessfully`\n',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration);

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, dioError401),
        );

        when(authenticationClient.refreshingTokensOIDC(
            OIDCFixtures.oidcConfiguration.clientId,
            OIDCFixtures.oidcConfiguration.redirectUrl,
            OIDCFixtures.oidcConfiguration.discoveryUrl,
            OIDCFixtures.oidcConfiguration.scopes,
            OIDCFixtures.tokenOidcExpiredTime.refreshToken
        )).thenAnswer((_) async {
          dioAdapter.onPost(
            baseUrl,
            (server) => server.reply(responseStatusCode200, dataRequestSuccessfully)
          );

          return OIDCFixtures.newTokenOidc;
        });

        when(accountCacheManager.getCurrentAccount()).thenAnswer((_) async => AccountFixtures.aliceAccount);

        final response = await dio.post(baseUrl);

        expect(response.statusCode, responseStatusCode200);
        expect(response.data, dataRequestSuccessfully);
      });

      test(
        'WHEN make a request with `tokenOidcExpiredTime`\n'
        'AND returns error `dioError401`\n'
        'THEN refresh token successfully received `newTokenOidc`\n'
        'AND `newTokenOidc` equals `tokenOidcExpiredTime` \n'
        'AND re-execute request with `newTokenOidc`\n'
        'THEN return error SHOULD `dioError401`\n',
      () async {
        authorizationInterceptors.setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcExpiredTime,
          newConfig: OIDCFixtures.oidcConfiguration);

        dioAdapter.onPost(
          baseUrl,
          (server) => server.throws(responseStatusCode401, dioError401)
        );

        when(authenticationClient.refreshingTokensOIDC(
          OIDCFixtures.oidcConfiguration.clientId,
          OIDCFixtures.oidcConfiguration.redirectUrl,
          OIDCFixtures.oidcConfiguration.discoveryUrl,
          OIDCFixtures.oidcConfiguration.scopes,
          OIDCFixtures.tokenOidcExpiredTime.refreshToken
        )).thenAnswer((_) async {
          dioAdapter.onPost(
            baseUrl,
            (server) => server.throws(responseStatusCode401, dioError401)
          );
          return OIDCFixtures.tokenOidcExpiredTime;
        });

        when(accountCacheManager.getCurrentAccount()).thenAnswer((_) async => AccountFixtures.aliceAccount);

        expect(
          () async => await dio.post(baseUrl),
          throwsA(predicate<DioError>((error) => error.response?.statusCode == responseStatusCode401))
        );
      });
    });
  });

  group('AuthorizationInterceptor: multiple requests queued on onError', () {
    final requestOneDioError401 = DioError(
      error: {'message': 'Token Expired'},
      requestOptions: RequestOptions(path: '$baseUrl/1', method: 'POST'),
      response: Response(
          statusCode: responseStatusCode401,
          requestOptions: RequestOptions(path: '$baseUrl/1')
      ),
      type: DioErrorType.badResponse,
    );

    final requestTwoDioError401 = DioError(
      error: {'message': 'Token Expired'},
      requestOptions: RequestOptions(
          path: '$baseUrl/2',
          method: 'POST',
          headers: {HttpHeaders.authorizationHeader: 'Bearer ${OIDCFixtures.tokenOidcExpiredTime.token}'}
      ),
      response: Response(
          statusCode: responseStatusCode401,
          requestOptions: RequestOptions(path: '$baseUrl/2')
      ),
      type: DioErrorType.badResponse,
    );

    test('GIVEN 2 requests have token expired\n'
        'AND Request 1 refresh token then execute succeeded\n'
        'THEN Request 2 must use new token to execute request', () async {

      authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: OIDCFixtures.tokenOidcExpiredTime,
        newConfig: OIDCFixtures.oidcConfiguration);

      dioAdapter.onPost(
        '$baseUrl/1',
        (server) => server.throws(responseStatusCode401, requestOneDioError401)
      );

      dioAdapter.onPost(
        '$baseUrl/2',
        (server) => server.throws(responseStatusCode401, requestTwoDioError401)
      );

      when(authenticationClient.refreshingTokensOIDC(
        OIDCFixtures.oidcConfiguration.clientId,
        OIDCFixtures.oidcConfiguration.redirectUrl,
        OIDCFixtures.oidcConfiguration.discoveryUrl,
        OIDCFixtures.oidcConfiguration.scopes,
        OIDCFixtures.tokenOidcExpiredTime.refreshToken
      )).thenAnswer((_) async {
        dioAdapter.onPost(
          '$baseUrl/1',
          (server) => server.reply(responseStatusCode200, dataRequestSuccessfully)
        );
        dioAdapter.onPost(
        '$baseUrl/2',
          (server) => server.reply(responseStatusCode200, dataRequestSuccessfully)
        );
        return OIDCFixtures.newTokenOidc;
      });

      when(accountCacheManager.getCurrentAccount()).thenAnswer((_) async => AccountFixtures.aliceAccount);
      when(accountCacheManager.deleteCurrentAccount(AccountFixtures.aliceAccount.id)).thenAnswer((_) async {});

      final responses = await Future.wait([
        dio.post('$baseUrl/1',),
        dio.post('$baseUrl/2',)
      ]);

      verify(authenticationClient.refreshingTokensOIDC(
        OIDCFixtures.oidcConfiguration.clientId,
        OIDCFixtures.oidcConfiguration.redirectUrl,
        OIDCFixtures.oidcConfiguration.discoveryUrl,
        OIDCFixtures.oidcConfiguration.scopes,
        OIDCFixtures.tokenOidcExpiredTime.refreshToken
      )).called(1);

      expect(responses.length, equals(2));
      expect(responses[0].statusCode, equals(HttpStatus.ok));
      expect(responses[0].requestOptions.headers[HttpHeaders.authorizationHeader], equals('Bearer ${OIDCFixtures.newTokenOidc.token}'));

      expect(responses[1].statusCode, equals(HttpStatus.ok));
      expect(responses[1].requestOptions.headers[HttpHeaders.authorizationHeader], equals('Bearer ${OIDCFixtures.newTokenOidc.token}'));
    });

    test('GIVEN 2 requests have token expired\n'
        'AND Request 1 refresh token then execute failed\n'
        'THEN Request 2 can not execute', () async {

      authorizationInterceptors.setTokenAndAuthorityOidc(
        newToken: OIDCFixtures.tokenOidcExpiredTime,
        newConfig: OIDCFixtures.oidcConfiguration);

      dioAdapter.onPost(
        '$baseUrl/1',
        (server) => server.throws(responseStatusCode401, requestOneDioError401)
      );

      dioAdapter.onPost(
        '$baseUrl/2',
        (server) => server.throws(responseStatusCode401, requestTwoDioError401)
      );

      when(authenticationClient.refreshingTokensOIDC(
        OIDCFixtures.oidcConfiguration.clientId,
        OIDCFixtures.oidcConfiguration.redirectUrl,
        OIDCFixtures.oidcConfiguration.discoveryUrl,
        OIDCFixtures.oidcConfiguration.scopes,
        OIDCFixtures.tokenOidcExpiredTime.refreshToken
      )).thenAnswer((_) async {
        throw AccessTokenInvalidException();
      });

      when(accountCacheManager.getCurrentAccount()).thenAnswer((_) async => AccountFixtures.aliceAccount);
      when(accountCacheManager.deleteCurrentAccount(AccountFixtures.aliceAccount.id)).thenAnswer((_) async {});

      expect(
        () async => await Future.wait([
          dio.post('$baseUrl/1',),
          dio.post('$baseUrl/2',)
        ]),
        throwsA(predicate<DioError>(
          (dioError) => dioError.error is AccessTokenInvalidException))
      );

      verifyZeroInteractions(authenticationClient);
    });
  });

  tearDown(() {
    dioAdapter.close();
    dio.close();
  });
}