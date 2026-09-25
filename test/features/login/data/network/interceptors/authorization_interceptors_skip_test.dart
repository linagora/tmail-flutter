import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/account/password.dart';
import 'package:tmail_ui_user/features/login/data/local/account_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_base.dart';
import 'package:tmail_ui_user/features/login/data/network/interceptors/authorization_interceptors.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class _FakeAuthenticationClient extends Fake implements AuthenticationClientBase {}

class _FakeTokenOidcCacheManager extends Fake implements TokenOidcCacheManager {}

class _FakeAccountCacheManager extends Fake implements AccountCacheManager {}

class _FakeIOSSharingManager extends Fake implements IOSSharingManager {}

void main() {
  late AuthorizationInterceptors interceptors;

  setUp(() {
    interceptors = AuthorizationInterceptors(
      Dio(),
      _FakeAuthenticationClient(),
      _FakeTokenOidcCacheManager(),
      _FakeAccountCacheManager(),
      _FakeIOSSharingManager(),
    );
    interceptors.setBasicAuthorization(UserName('alice'), Password('secret'));
  });

  RequestOptions intercept(RequestOptions options) {
    interceptors.onRequest(options, RequestInterceptorHandler());
    return options;
  }

  test('SHOULD attach credentials to regular requests', () {
    final options = intercept(RequestOptions(path: 'https://jmap.example.com/jmap'));

    expect(options.headers[HttpHeaders.authorizationHeader], startsWith('Basic '));
  });

  test('SHOULD NOT attach credentials when the request opts out', () {
    final options = intercept(RequestOptions(
      path: 'https://guessed.example.org/.well-known/webfinger',
      extra: {AuthorizationInterceptors.skipAuthorizationKey: true},
    ));

    expect(options.headers.containsKey(HttpHeaders.authorizationHeader), isFalse);
  });
}
