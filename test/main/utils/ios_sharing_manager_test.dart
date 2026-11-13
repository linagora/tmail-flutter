import 'package:core/utils/sentry/sentry_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/state.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:mockito/mockito.dart';
import 'package:model/account/authentication_type.dart';
import 'package:model/account/personal_account.dart';
import 'package:tmail_ui_user/features/login/data/local/authentication_info_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/oidc_configuration_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';
import 'package:tmail_ui_user/features/login/data/network/oidc_http_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/mailbox_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/local/state_cache_manager.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_type.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_delegated_account.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_manager.dart';
import 'package:tmail_ui_user/features/push_notification/data/keychain/keychain_sharing_session.dart';
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

class _FakeAuthenticationInfoCacheManager extends Fake
    implements AuthenticationInfoCacheManager {
  @override
  Future<AuthenticationInfoCache> getAuthenticationInfoStored() async {
    return AuthenticationInfoCache('user@domain.com', 'secret');
  }
}

class _FakeStateCacheManager extends Fake implements StateCacheManager {
  @override
  Future<State?> getState(AccountId accountId, UserName userName, StateType stateType) async {
    return null;
  }
}

class _FakeMailboxCacheManager extends Fake implements MailboxCacheManager {
  @override
  Future<List<Mailbox>> getAllMailbox(AccountId accountId, UserName userName) async {
    return [];
  }
}

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

  test('saveKeyChainSharingSession keeps delegatedAccounts of an existing entry', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final keychainSharingManager = KeychainSharingManager(const FlutterSecureStorage());
    final accountId = AccountId(Id('personal-account'));
    final userName = UserName('user@domain.com');
    final delegated = KeychainDelegatedAccount(
      accountId: AccountId(Id('delegated-account')),
      emailDeliveryState: 'delivery-1',
    );
    await keychainSharingManager.saveSharingSession(
      KeychainSharingSession(
        accountId: accountId,
        userName: userName,
        authenticationType: AuthenticationType.basic,
        apiUrl: 'https://jmap.example/jmap',
        emailDeliveryState: 'old-delivery',
        delegatedAccounts: [delegated],
      ),
    );

    final iosSharingManager = IOSSharingManager(
      keychainSharingManager,
      _FakeStateCacheManager(),
      _MockTokenOidcCacheManager(),
      _FakeAuthenticationInfoCacheManager(),
      _MockOidcConfigurationCacheManager(),
      _MockOIDCHttpClient(),
      _FakeMailboxCacheManager(),
    );

    await iosSharingManager.saveKeyChainSharingSession(
      PersonalAccount(
        'hash-id',
        AuthenticationType.basic,
        isSelected: true,
        accountId: accountId,
        apiUrl: 'https://jmap.example/jmap',
        userName: userName,
      ),
    );

    final saved = await keychainSharingManager.getSharingSession(accountId);
    expect(saved?.delegatedAccounts, [delegated]);
  });
}
