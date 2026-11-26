import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/password.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/main/exceptions/remote/authentication_exception.dart';
import 'package:tmail_ui_user/main/exceptions/thrower/remote_exception_thrower.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

import '../../../../../fixtures/oidc_fixtures.dart';

class _FakeAuthenticationClient extends Fake implements AuthenticationClientBase {}

class _FakeTokenOidcCacheManager extends Fake implements TokenOidcCacheManager {}

class _FakeAccountCacheManager extends Fake implements AccountCacheManager {}

class _FakeIOSSharingManager extends Fake implements IOSSharingManager {}

void main() {
  var revoked = false;
  var checks = 0;

  AuthorizationInterceptors newInterceptors({bool withCallback = true}) {
    return AuthorizationInterceptors(
      Dio(),
      _FakeAuthenticationClient(),
      _FakeTokenOidcCacheManager(),
      _FakeAccountCacheManager(),
      _FakeIOSSharingManager(),
      isBasicLoginRevoked: withCallback
          ? () {
              checks++;
              return revoked;
            }
          : null,
    );
  }

  setUp(() {
    revoked = false;
    checks = 0;
  });

  // dio completes the handler future normally on next and with the state on reject;
  // the state type is not exported, so only its data is read.
  Future<({bool rejected, dynamic data})> intercept(
    AuthorizationInterceptors interceptors,
    RequestOptions options,
  ) async {
    final handler = RequestInterceptorHandler();
    interceptors.onRequest(options, handler);
    try {
      final state = await handler.future;
      return (rejected: false, data: state.data);
    } catch (state) {
      return (rejected: true, data: (state as dynamic).data);
    }
  }

  RequestOptions request({Map<String, dynamic>? headers}) =>
      RequestOptions(path: 'https://jmap.example.com/jmap', headers: headers);

  group('basic login', () {
    late AuthorizationInterceptors interceptors;

    setUp(() {
      interceptors = newInterceptors()
        ..setBasicAuthorization(UserName('alice'), Password('secret'));
    });

    test('revoked login rejects the request with CredentialRevokedException', () async {
      revoked = true;
      final options = request();

      final state = await intercept(interceptors, options);

      expect(state.rejected, isTrue);
      final error = state.data as DioException;
      expect(error.error, isA<CredentialRevokedException>());
      expect(options.headers.containsKey(HttpHeaders.authorizationHeader), isFalse);
    });

    test('revoked login strips an Authorization header the request already carried', () async {
      revoked = true;
      final options = request(headers: {HttpHeaders.authorizationHeader: 'Basic leaked'});

      final state = await intercept(interceptors, options);

      expect(state.rejected, isTrue);
      expect(options.headers.containsKey(HttpHeaders.authorizationHeader), isFalse);
    });

    test('valid login still attaches credentials and continues', () async {
      final options = request();

      final state = await intercept(interceptors, options);

      expect(state.rejected, isFalse);
      expect(options.headers[HttpHeaders.authorizationHeader], startsWith('Basic '));
    });

    test('a request that opts out of authorization skips the revocation check', () async {
      revoked = true;
      final options = RequestOptions(
        path: 'https://guessed.example.org/.well-known/webfinger',
        extra: {AuthorizationInterceptors.skipAuthorizationKey: true},
      );

      final state = await intercept(interceptors, options);

      expect(state.rejected, isFalse);
      expect(checks, 0);
    });

    test('without a callback the request is sent as before', () async {
      final plain = newInterceptors(withCallback: false)
        ..setBasicAuthorization(UserName('alice'), Password('secret'));

      final state = await intercept(plain, request());

      expect(state.rejected, isFalse);
    });
  });

  group('other authentication types', () {
    test('oidc is never checked for revocation', () async {
      revoked = true;
      final interceptors = newInterceptors()
        ..setTokenAndAuthorityOidc(
          newToken: OIDCFixtures.tokenOidcNotExpiredYet,
          newConfig: OIDCFixtures.oidcConfiguration,
        );
      final options = request();

      final state = await intercept(interceptors, options);

      expect(state.rejected, isFalse);
      expect(options.headers[HttpHeaders.authorizationHeader], startsWith('Bearer '));
      expect(checks, 0);
    });

    test('unauthenticated requests are never checked for revocation', () async {
      revoked = true;

      final state = await intercept(newInterceptors(), request());

      expect(state.rejected, isFalse);
      expect(checks, 0);
    });
  });

  group('CredentialRevokedException', () {
    test('is not mapped to BadCredentialsException by the remote exception thrower', () {
      final error = DioException(
        requestOptions: RequestOptions(path: '/jmap'),
        error: const CredentialRevokedException(),
      );

      expect(
        () => RemoteExceptionThrower().handleDioError(error),
        throwsA(isA<CredentialRevokedException>()),
      );
      expect(
        () => RemoteExceptionThrower().handleDioError(error),
        throwsA(isNot(isA<BadCredentialsException>())),
      );
    });
  });
}
