import 'package:flutter/services.dart';
import 'package:flutter_appauth_platform_interface/flutter_appauth_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_interaction_mixin.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/oauth_authorization_error.dart';

/// The mixin declares no `on` clause, so a bare host class is enough to
/// exercise [AuthenticationClientInteractionMixin.handleException].
class _TestAuthClient with AuthenticationClientInteractionMixin {}

void main() {
  late _TestAuthClient authClient;

  setUp(() => authClient = _TestAuthClient());

  group('AuthenticationClientInteractionMixin::handleException '
      '- converts an AppAuth OAuth error', () {
    test('maps an RFC 6749 code to OAuthAuthorizationError', () {
      final result = authClient.handleException(_appAuthException(
        error: 'invalid_grant',
        errorDescription: 'The refresh token has been revoked',
      ));

      expect(result, isA<OAuthAuthorizationError>());
      expect((result as OAuthAuthorizationError).error, 'invalid_grant');
      expect(result.message, 'The refresh token has been revoked');
    });

    // The interceptor's network tolerance keys off the subtype, not the string,
    // so a transient SSO failure must arrive as its dedicated type. The codes
    // below are spelled out as literals on purpose: they are what the server
    // puts on the wire, so renaming the matching constant must fail here.
    test('maps server_error to the ServerError subtype', () {
      final result = authClient.handleException(_appAuthException(
        error: 'server_error',
        errorDescription: 'Internal server error',
      ));

      expect(result, isA<ServerError>());
      expect((result as ServerError).message, 'Internal server error');
    });

    test('maps temporarily_unavailable to the TemporarilyUnavailable subtype',
        () {
      final result = authClient.handleException(_appAuthException(
        error: 'temporarily_unavailable',
        errorDescription: 'Service is down for maintenance',
      ));

      expect(result, isA<TemporarilyUnavailable>());
      expect(
        (result as TemporarilyUnavailable).message,
        'Service is down for maintenance',
      );
    });

    // A valid RFC 6749 code with no dedicated subtype must land on the base
    // type — this is the only cover for fromErrorCode's default branch.
    test('maps a code with no subtype to the base type, null description kept',
        () {
      final result = authClient.handleException(
        _appAuthException(error: 'invalid_client'),
      );

      expect(result, isA<OAuthAuthorizationError>());
      expect(result, isNot(isA<ServerError>()));
      expect(result, isNot(isA<TemporarilyUnavailable>()));
      expect((result as OAuthAuthorizationError).error, 'invalid_client');
      expect(result.message, isNull);
    });
  });

  group('AuthenticationClientInteractionMixin::handleException '
      '- passes through what it cannot classify', () {
    // A network/DNS failure reaches the app with no OAuth error field. It must
    // stay a PlatformException so the refresh-then-retry path keeps the session
    // instead of signing the user out on a flaky connection.
    test('returns an AppAuth exception with no OAuth code unchanged', () {
      final exception = _appAuthException(message: 'Network error');

      expect(authClient.handleException(exception), same(exception));
    });

    test('returns a plain PlatformException unchanged', () {
      final exception = PlatformException(code: 'unknown');

      expect(authClient.handleException(exception), same(exception));
    });

    test('returns a non-AppAuth exception unchanged', () {
      final exception = Exception('boom');

      expect(authClient.handleException(exception), same(exception));
    });

    // The mixin is shared with the web client, whose plugin reports failures as
    // ArgumentError — an Error, not an Exception. The signature is `dynamic`,
    // so this must survive the boundary for the web classifier to see it.
    test('returns an Error, not just an Exception, unchanged', () {
      final error = ArgumentError(
        'Failed to get token: [error: invalid_grant, description: revoked]',
      );

      expect(authClient.handleException(error), same(error));
    });
  });
}

/// Mirrors the shape the plugin builds from a token-endpoint failure: [code] is
/// the plugin-level code, while [error] is the RFC 6749 code read out of the
/// response body (null whenever the failure never reached the OAuth server).
FlutterAppAuthPlatformException _appAuthException({
  String code = 'token_failed',
  String message = 'Failed to get token',
  String? error,
  String? errorDescription,
}) {
  return FlutterAppAuthPlatformException(
    code: code,
    message: message,
    platformErrorDetails: FlutterAppAuthPlatformErrorDetails(
      error: error,
      errorDescription: errorDescription,
    ),
  );
}
