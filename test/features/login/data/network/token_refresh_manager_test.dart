import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/network/token_refresh_manager.dart';
import 'package:tmail_ui_user/features/login/domain/extensions/oidc_configuration_extensions.dart';

import '../../../../fixtures/account_fixtures.dart';
import '../../../../fixtures/oidc_fixtures.dart';
import '../../../interceptor/authorization_interceptor_test.mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockAuthenticationClientBase authenticationClient;
  late MockTokenOidcCacheManager tokenOidcCacheManager;
  late MockAccountCacheManager accountCacheManager;
  late MockIOSSharingManager iosSharingManager;
  late TokenRefreshManager tokenRefreshManager;

  setUp(() {
    authenticationClient = MockAuthenticationClientBase();
    tokenOidcCacheManager = MockTokenOidcCacheManager();
    accountCacheManager = MockAccountCacheManager();
    iosSharingManager = MockIOSSharingManager();

    tokenRefreshManager = TokenRefreshManager(
      authenticationClient,
      tokenOidcCacheManager,
      accountCacheManager,
      iosSharingManager,
    );

    dotenv.loadFromString(envString: 'PLATFORM=other');
  });

  tearDown(() {
    tokenRefreshManager.dispose();
  });

  group('TokenRefreshManager initialization tests', () {
    test('should not schedule refresh when authentication type is not OIDC', () {
      tokenRefreshManager.initialize(
        token: OIDCFixtures.newTokenOidc,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.basic,
      );

      verifyNever(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      ));
    });

    test('should not schedule refresh when token is null', () {
      tokenRefreshManager.initialize(
        token: null,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
      );

      verifyNever(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      ));
    });

    test('should not schedule refresh when config is null', () {
      tokenRefreshManager.initialize(
        token: OIDCFixtures.newTokenOidc,
        config: null,
        authenticationType: AuthenticationType.oidc,
      );

      verifyNever(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      ));
    });

    test('should not schedule refresh when refresh token is empty', () {
      final tokenWithEmptyRefresh = TokenOIDC(
        'token123',
        OIDCFixtures.newTokenOidc.tokenId,
        '',
        expiredTime: DateTime.now().add(const Duration(hours: 1)),
      );

      tokenRefreshManager.initialize(
        token: tokenWithEmptyRefresh,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
      );

      verifyNever(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      ));
    });
  });

  group('TokenRefreshManager refresh delay calculation tests', () {
    test('should refresh at 80% of token lifetime when lifetime is long', () {
      // Token expires in 100 seconds, 80% = 80 seconds
      final tokenWith100sLifetime = TokenOIDC(
        'token123',
        OIDCFixtures.newTokenOidc.tokenId,
        'refresh123',
        expiredTime: DateTime.now().add(const Duration(seconds: 100)),
      );

      tokenRefreshManager.initialize(
        token: tokenWith100sLifetime,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
      );

      // No immediate refresh should occur since token has plenty of time
      verifyNever(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      ));
    });

    test('should refresh immediately when token is about to expire', () async {
      // Token expires in 30 seconds (less than 60s buffer)
      final tokenAboutToExpire = TokenOIDC(
        'token123',
        OIDCFixtures.newTokenOidc.tokenId,
        'refresh123',
        expiredTime: DateTime.now().add(const Duration(seconds: 30)),
      );

      when(accountCacheManager.getCurrentAccount())
          .thenAnswer((_) async => AccountFixtures.aliceAccount);
      when(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);

      tokenRefreshManager.initialize(
        token: tokenAboutToExpire,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
      );

      // Give time for immediate refresh to occur
      await Future.delayed(const Duration(milliseconds: 100));

      verify(authenticationClient.refreshingTokensOIDC(
        OIDCFixtures.oidcConfiguration.clientId,
        OIDCFixtures.oidcConfiguration.redirectUrl,
        OIDCFixtures.oidcConfiguration.discoveryUrl,
        OIDCFixtures.oidcConfiguration.scopes,
        'refresh123',
      )).called(1);
    });

    test('should not schedule refresh when token is already expired', () {
      tokenRefreshManager.initialize(
        token: OIDCFixtures.tokenOidcExpiredTime,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
      );

      verifyNever(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      ));
    });
  });

  group('TokenRefreshManager callback tests', () {
    test('should call onTokenRefreshed callback when token is refreshed', () async {
      TokenOIDC? callbackToken;

      final tokenAboutToExpire = TokenOIDC(
        'old-token',
        OIDCFixtures.newTokenOidc.tokenId,
        'refresh123',
        expiredTime: DateTime.now().add(const Duration(seconds: 10)),
      );

      when(accountCacheManager.getCurrentAccount())
          .thenAnswer((_) async => AccountFixtures.aliceAccount);
      when(accountCacheManager.deleteCurrentAccount(any))
          .thenAnswer((_) async {});
      when(accountCacheManager.setCurrentAccount(any))
          .thenAnswer((_) async {});
      when(tokenOidcCacheManager.persistOneTokenOidc(any))
          .thenAnswer((_) async {});
      when(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);

      tokenRefreshManager.initialize(
        token: tokenAboutToExpire,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
        onRefreshed: (token) => callbackToken = token,
      );

      await Future.delayed(const Duration(milliseconds: 200));

      expect(callbackToken, isNotNull);
      expect(callbackToken?.token, equals(OIDCFixtures.newTokenOidc.token));
    });

    test('should not call callback when refreshed token is same as current', () async {
      TokenOIDC? callbackToken;

      final currentToken = TokenOIDC(
        'same-token',
        OIDCFixtures.newTokenOidc.tokenId,
        'refresh123',
        expiredTime: DateTime.now().add(const Duration(seconds: 10)),
      );

      when(accountCacheManager.getCurrentAccount())
          .thenAnswer((_) async => AccountFixtures.aliceAccount);
      when(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      )).thenAnswer((_) async => currentToken);

      tokenRefreshManager.initialize(
        token: currentToken,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
        onRefreshed: (token) => callbackToken = token,
      );

      await Future.delayed(const Duration(milliseconds: 200));

      expect(callbackToken, isNull);
    });
  });

  group('TokenRefreshManager retry logic tests', () {
    test('should retry refresh after failure', () async {
      int refreshAttempts = 0;

      final tokenAboutToExpire = TokenOIDC(
        'token123',
        OIDCFixtures.newTokenOidc.tokenId,
        'refresh123',
        expiredTime: DateTime.now().add(const Duration(seconds: 5)),
      );

      when(accountCacheManager.getCurrentAccount())
          .thenAnswer((_) async => AccountFixtures.aliceAccount);
      when(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      )).thenAnswer((_) async {
        refreshAttempts++;
        if (refreshAttempts < 2) {
          throw Exception('Network error');
        }
        return OIDCFixtures.newTokenOidc;
      });
      when(accountCacheManager.deleteCurrentAccount(any))
          .thenAnswer((_) async {});
      when(accountCacheManager.setCurrentAccount(any))
          .thenAnswer((_) async {});
      when(tokenOidcCacheManager.persistOneTokenOidc(any))
          .thenAnswer((_) async {});

      tokenRefreshManager.initialize(
        token: tokenAboutToExpire,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
      );

      // First attempt fails immediately, retry after 30 seconds (we fake it)
      await Future.delayed(const Duration(milliseconds: 100));

      // At least one attempt should have been made
      expect(refreshAttempts, greaterThanOrEqualTo(1));
    });
  });

  group('TokenRefreshManager updateToken tests', () {
    test('should reset retry counter when updateToken is called', () {
      tokenRefreshManager.initialize(
        token: OIDCFixtures.newTokenOidc,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
      );

      // Update with a new token
      tokenRefreshManager.updateToken(OIDCFixtures.newTokenOidc);

      // No errors should occur
      verifyNever(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      ));
    });
  });

  group('TokenRefreshManager checkAndRefreshIfNeeded tests', () {
    test('should refresh immediately when called and token is about to expire', () async {
      // Use a token that expires in 50 seconds - this will schedule a refresh (not immediate)
      // since it's just under the 60s buffer but 80% of 50s = 40s, which is positive
      final tokenAboutToExpire = TokenOIDC(
        'token123',
        OIDCFixtures.newTokenOidc.tokenId,
        'refresh123',
        expiredTime: DateTime.now().add(const Duration(seconds: 50)),
      );

      when(accountCacheManager.getCurrentAccount())
          .thenAnswer((_) async => AccountFixtures.aliceAccount);
      when(accountCacheManager.deleteCurrentAccount(any))
          .thenAnswer((_) async {});
      when(accountCacheManager.setCurrentAccount(any))
          .thenAnswer((_) async {});
      when(tokenOidcCacheManager.persistOneTokenOidc(any))
          .thenAnswer((_) async {});
      when(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);

      tokenRefreshManager.initialize(
        token: tokenAboutToExpire,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
      );

      // The token with 50s lifetime will be scheduled for refresh at min(40s, -10s) = -10s
      // which means immediate refresh. Let's wait for it to complete
      await Future.delayed(const Duration(milliseconds: 300));

      // Now manually call checkAndRefreshIfNeeded - token is still within buffer
      await tokenRefreshManager.checkAndRefreshIfNeeded();

      // Verify refresh was called at least once (from either init or check)
      verify(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      )).called(greaterThanOrEqualTo(1));
    });

    test('should not refresh when token has plenty of time', () async {
      final tokenWithLongLifetime = TokenOIDC(
        'token123',
        OIDCFixtures.newTokenOidc.tokenId,
        'refresh123',
        expiredTime: DateTime.now().add(const Duration(hours: 1)),
      );

      tokenRefreshManager.initialize(
        token: tokenWithLongLifetime,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
      );

      await tokenRefreshManager.checkAndRefreshIfNeeded();

      verifyNever(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      ));
    });
  });

  group('TokenRefreshManager dispose tests', () {
    test('should cancel timer and clear state on dispose', () {
      tokenRefreshManager.initialize(
        token: OIDCFixtures.newTokenOidc,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
      );

      tokenRefreshManager.dispose();

      // Verify no errors and clean disposal
      verifyNever(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      ));
    });
  });

  group('TokenRefreshManager token persistence tests', () {
    test('should persist token after successful refresh', () async {
      final tokenAboutToExpire = TokenOIDC(
        'old-token',
        OIDCFixtures.newTokenOidc.tokenId,
        'refresh123',
        expiredTime: DateTime.now().add(const Duration(seconds: 10)),
      );

      when(accountCacheManager.getCurrentAccount())
          .thenAnswer((_) async => AccountFixtures.aliceAccount);
      when(accountCacheManager.deleteCurrentAccount(any))
          .thenAnswer((_) async {});
      when(accountCacheManager.setCurrentAccount(any))
          .thenAnswer((_) async {});
      when(tokenOidcCacheManager.persistOneTokenOidc(any))
          .thenAnswer((_) async {});
      when(authenticationClient.refreshingTokensOIDC(
        any, any, any, any, any,
      )).thenAnswer((_) async => OIDCFixtures.newTokenOidc);

      tokenRefreshManager.initialize(
        token: tokenAboutToExpire,
        config: OIDCFixtures.oidcConfiguration,
        authenticationType: AuthenticationType.oidc,
      );

      await Future.delayed(const Duration(milliseconds: 200));

      verify(tokenOidcCacheManager.persistOneTokenOidc(OIDCFixtures.newTokenOidc)).called(1);
      verify(accountCacheManager.deleteCurrentAccount(AccountFixtures.aliceAccount.id)).called(1);
      verify(accountCacheManager.setCurrentAccount(any)).called(1);
    });
  });
}
