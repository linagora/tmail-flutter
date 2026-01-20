import 'package:flutter_test/flutter_test.dart';
import 'package:model/oidc/oidc_configuration.dart';
import 'package:model/oidc/response/oidc_discovery_response.dart';
import 'package:model/oidc/token_id.dart';
import 'package:tmail_ui_user/features/login/data/network/authentication_client/authentication_client_interaction_mixin.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

// Test class that uses the mixin
class TestAuthenticationClient with AuthenticationClientInteractionMixin {}

void main() {
  late TestAuthenticationClient client;

  setUp(() {
    client = TestAuthenticationClient();
  });

  group('hasEndSessionEndpoint', () {
    test('should return true when end_session_endpoint is present', () {
      // arrange
      final discoveryResponse = OIDCDiscoveryResponse(
        'https://example.com/auth',
        'https://example.com/token',
        'https://example.com/logout',
        'https://example.com/userinfo',
      );

      // act
      final result = client.hasEndSessionEndpoint(discoveryResponse);

      // assert
      expect(result, isTrue);
    });

    test('should return false when end_session_endpoint is null', () {
      // arrange
      final discoveryResponse = OIDCDiscoveryResponse(
        'https://example.com/auth',
        'https://example.com/token',
        null, // end_session_endpoint is null
        'https://example.com/userinfo',
      );

      // act
      final result = client.hasEndSessionEndpoint(discoveryResponse);

      // assert
      expect(result, isFalse);
    });
  });

  group('validateOidcDiscoveryResponse', () {
    test('should not throw when all required endpoints are present', () {
      // arrange
      final discoveryResponse = OIDCDiscoveryResponse(
        'https://example.com/auth',
        'https://example.com/token',
        'https://example.com/logout',
        'https://example.com/userinfo',
      );

      // act & assert
      expect(
        () => client.validateOidcDiscoveryResponse(discoveryResponse),
        returnsNormally,
      );
    });

    test('should throw MissingAuthorizationEndpointException when authorization_endpoint is null', () {
      // arrange
      final discoveryResponse = OIDCDiscoveryResponse(
        null, // authorization_endpoint is null
        'https://example.com/token',
        'https://example.com/logout',
        'https://example.com/userinfo',
      );

      // act & assert
      expect(
        () => client.validateOidcDiscoveryResponse(discoveryResponse),
        throwsA(isA<MissingAuthorizationEndpointException>()),
      );
    });

    test('should throw MissingTokenEndpointException when token_endpoint is null', () {
      // arrange
      final discoveryResponse = OIDCDiscoveryResponse(
        'https://example.com/auth',
        null, // token_endpoint is null
        'https://example.com/logout',
        'https://example.com/userinfo',
      );

      // act & assert
      expect(
        () => client.validateOidcDiscoveryResponse(discoveryResponse),
        throwsA(isA<MissingTokenEndpointException>()),
      );
    });

    test('should throw MissingAuthorizationEndpointException first when both are null', () {
      // arrange
      final discoveryResponse = OIDCDiscoveryResponse(
        null, // authorization_endpoint is null
        null, // token_endpoint is null
        'https://example.com/logout',
        'https://example.com/userinfo',
      );

      // act & assert - should throw authorization exception first
      expect(
        () => client.validateOidcDiscoveryResponse(discoveryResponse),
        throwsA(isA<MissingAuthorizationEndpointException>()),
      );
    });
  });

  group('getEndSessionRequest', () {
    OIDCConfiguration createTestConfig() {
      return OIDCConfiguration(
        authority: 'https://example.com',
        clientId: 'test-client-id',
        scopes: ['openid', 'profile', 'email'],
      );
    }

    test('should return null when end_session_endpoint is missing', () {
      // arrange
      final tokenId = TokenId('test-token-id');
      final config = createTestConfig();
      final discoveryResponse = OIDCDiscoveryResponse(
        'https://example.com/auth',
        'https://example.com/token',
        null, // end_session_endpoint is null
        'https://example.com/userinfo',
      );

      // act
      final result = client.getEndSessionRequest(tokenId, config, discoveryResponse);

      // assert
      expect(result, isNull);
    });

    test('should return EndSessionRequest when end_session_endpoint is present', () {
      // arrange
      final tokenId = TokenId('test-token-id');
      final config = createTestConfig();
      final discoveryResponse = OIDCDiscoveryResponse(
        'https://example.com/auth',
        'https://example.com/token',
        'https://example.com/logout',
        'https://example.com/userinfo',
      );

      // act
      final result = client.getEndSessionRequest(tokenId, config, discoveryResponse);

      // assert
      expect(result, isNotNull);
      expect(result!.idTokenHint, 'test-token-id');
    });

    test('should include service configuration when auth and token endpoints present', () {
      // arrange
      final tokenId = TokenId('test-token-id');
      final config = createTestConfig();
      final discoveryResponse = OIDCDiscoveryResponse(
        'https://example.com/auth',
        'https://example.com/token',
        'https://example.com/logout',
        'https://example.com/userinfo',
      );

      // act
      final result = client.getEndSessionRequest(tokenId, config, discoveryResponse);

      // assert
      expect(result, isNotNull);
      expect(result!.serviceConfiguration, isNotNull);
      expect(result.serviceConfiguration!.authorizationEndpoint, 'https://example.com/auth');
      expect(result.serviceConfiguration!.tokenEndpoint, 'https://example.com/token');
      expect(result.serviceConfiguration!.endSessionEndpoint, 'https://example.com/logout');
    });

    test('should have null service configuration when auth endpoint is missing', () {
      // arrange
      final tokenId = TokenId('test-token-id');
      final config = createTestConfig();
      final discoveryResponse = OIDCDiscoveryResponse(
        null, // authorization_endpoint is null
        'https://example.com/token',
        'https://example.com/logout',
        'https://example.com/userinfo',
      );

      // act
      final result = client.getEndSessionRequest(tokenId, config, discoveryResponse);

      // assert
      expect(result, isNotNull);
      expect(result!.serviceConfiguration, isNull);
    });
  });
}
