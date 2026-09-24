import 'package:core/utils/sentry/sentry_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/main/utils/ios_sharing_manager.dart';

class _FailingKeychainSharingManager extends KeychainSharingManager {
  _FailingKeychainSharingManager() : super(const FlutterSecureStorage());

  bool deleteSentryConfigCalled = false;

  @override
  Future<void> saveSentryConfig(SentryConfig sentryConfig) async {
    throw StateError('keychain write failed');
  }

  @override
  Future<void> deleteSentryConfig() async {
    deleteSentryConfigCalled = true;
  }
}

class _MockStateCacheManager extends Mock implements StateCacheManager {}

class _MockTokenOidcCacheManager extends Mock implements TokenOidcCacheManager {}

class _MockAuthenticationInfoCacheManager extends Mock
    implements AuthenticationInfoCacheManager {}

class _MockOidcConfigurationCacheManager extends Mock
    implements OidcConfigurationCacheManager {}

class _MockOIDCHttpClient extends Mock implements OIDCHttpClient {}

class _MockMailboxCacheManager extends Mock implements MailboxCacheManager {}

void main() {
  test('saveSentryConfigToKeychain propagates write failures', () async {
    final keychainSharingManager = _FailingKeychainSharingManager();
    final iosSharingManager = IOSSharingManager(
      keychainSharingManager,
      _MockStateCacheManager(),
      _MockTokenOidcCacheManager(),
      _MockAuthenticationInfoCacheManager(),
      _MockOidcConfigurationCacheManager(),
      _MockOIDCHttpClient(),
      _MockMailboxCacheManager(),
    );
    final sentryConfig = SentryConfig(
      dsn: 'https://test@sentry.io/123',
      environment: 'test',
      release: '1.0.0',
      isReportingAllowed: false,
    );

    await expectLater(
      iosSharingManager.saveSentryConfigToKeychain(sentryConfig),
      throwsStateError,
    );
    expect(keychainSharingManager.deleteSentryConfigCalled, isTrue);
  });
}
