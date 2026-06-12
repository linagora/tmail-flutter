import 'package:flutter_test/flutter_test.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

import 'memory_token_oidc_cache_client.dart';
import 'stub_token_oidc_cache_clients.dart';

void main() {
  final validToken = TokenOIDC(
    'access-token-abc',
    TokenId('token-id-123'),
    'refresh-token-xyz',
    expiredTime: DateTime(2099),
  );
  const tokenIdHash = 'hash-key-abc';

  group('getTokenOidc — happy path', () {
    late MemoryTokenOidcCacheClient cacheClient;
    late TokenOidcCacheManager manager;

    setUp(() {
      cacheClient = MemoryTokenOidcCacheClient();
      manager = TokenOidcCacheManager(cacheClient);
    });

    test('WHEN cache is empty\n'
        'THEN throws NotFoundStoredTokenException', () async {
      await expectLater(
        manager.getTokenOidc(tokenIdHash),
        throwsA(isA<NotFoundStoredTokenException>()),
      );
    });

    test('WHEN cache holds a token for the given hash\n'
        'THEN returns the matching TokenOIDC', () async {
      await cacheClient.insertItem(tokenIdHash, validToken.toTokenOidcCache());

      final result = await manager.getTokenOidc(tokenIdHash);

      expect(result.token, validToken.token);
      expect(result.tokenId.uuid, validToken.tokenId.uuid);
      expect(result.refreshToken, validToken.refreshToken);
    });

    test('WHEN a different hash key is requested\n'
        'THEN throws NotFoundStoredTokenException', () async {
      await cacheClient.insertItem('other-hash', validToken.toTokenOidcCache());

      await expectLater(
        manager.getTokenOidc(tokenIdHash),
        throwsA(isA<NotFoundStoredTokenException>()),
      );
    });
  });

  group('getTokenOidc — corrupted box recovery', () {
    test('WHEN getItem throws ArgumentError (AES block-size mismatch)\n'
        'THEN clears the box and throws NotFoundStoredTokenException', () async {
      final client = StubTokenOidcCacheClient.withCorruptedGetItem();
      final manager = TokenOidcCacheManager(client);

      await expectLater(
        manager.getTokenOidc(tokenIdHash),
        throwsA(isA<NotFoundStoredTokenException>()),
      );
      expect(client.clearCalled, isTrue,
          reason: 'corrupted box must be cleared to prevent repeated failures');
    });

    test('WHEN getItem throws a generic Error\n'
        'THEN clears the box and throws NotFoundStoredTokenException', () async {
      final client = StubTokenOidcCacheClient.withArbitraryGetItemError();
      final manager = TokenOidcCacheManager(client);

      await expectLater(
        manager.getTokenOidc(tokenIdHash),
        throwsA(isA<NotFoundStoredTokenException>()),
      );
      expect(client.clearCalled, isTrue);
    });

    test('WHEN clearAllData itself throws\n'
        'THEN the secondary error is suppressed and NotFoundStoredTokenException is still thrown', () async {
      final client = StubTokenOidcCacheClient.withClearFailing();
      final manager = TokenOidcCacheManager(client);

      await expectLater(
        manager.getTokenOidc(tokenIdHash),
        throwsA(isA<NotFoundStoredTokenException>()),
      );
      expect(client.clearCalled, isTrue);
    });
  });

  group('persistOneTokenOidc — corrupted box recovery', () {
    test('WHEN getMapItems throws during _removeStaleTokens\n'
        'THEN clears box and re-inserts token without throwing', () async {
      final client = StubTokenOidcCacheClient.withCorruptedGetMapItems();
      final manager = TokenOidcCacheManager(client);

      await expectLater(
        manager.persistOneTokenOidc(validToken),
        completes,
        reason: 'corrupted getMapItems must not propagate from persistOneTokenOidc',
      );

      expect(client.clearCalled, isTrue,
          reason: 'corrupted box must be cleared during recovery');

      final result = await manager.getTokenOidc(validToken.tokenIdHash);
      expect(result.token, validToken.token,
          reason: 'token must be readable after recovery re-insert');
    });

    test('WHEN getMapItems throws during _removeStaleTokens AND re-insert after clear also throws\n'
        'THEN error is suppressed and persistOneTokenOidc completes without throwing', () async {
      final client = StubTokenOidcCacheClient.withCorruptedGetMapItemsAndReInsertFailing();
      final manager = TokenOidcCacheManager(client);

      await expectLater(
        manager.persistOneTokenOidc(validToken),
        completes,
        reason: 're-insert failure after clear must not propagate from persistOneTokenOidc',
      );

      expect(client.clearCalled, isTrue,
          reason: 'box must still be cleared even when re-insert fails');
    });

    test('WHEN insertItem itself throws\n'
        'THEN exception propagates immediately without touching recovery path', () async {
      final client = StubTokenOidcCacheClient.withInsertFailing();
      final manager = TokenOidcCacheManager(client);

      await expectLater(
        manager.persistOneTokenOidc(validToken),
        throwsA(isA<StateError>()),
        reason: 'insertItem failure must propagate; box must not be cleared',
      );

      expect(client.clearCalled, isFalse,
          reason: 'recovery path must not be triggered by an insertItem failure');
    });
  });

  group('persistOneTokenOidc → getTokenOidc round-trip', () {
    late MemoryTokenOidcCacheClient cacheClient;
    late TokenOidcCacheManager manager;

    setUp(() {
      cacheClient = MemoryTokenOidcCacheClient();
      manager = TokenOidcCacheManager(cacheClient);
    });

    test('WHEN token is persisted\n'
        'THEN getTokenOidc returns the same token', () async {
      await manager.persistOneTokenOidc(validToken);

      final result = await manager.getTokenOidc(validToken.tokenIdHash);

      expect(result.token, validToken.token);
      expect(result.refreshToken, validToken.refreshToken);
    });

    test('WHEN a new token is persisted\n'
        'THEN old token is pruned and only new one is readable', () async {
      final oldToken = TokenOIDC(
        'old-access',
        TokenId('old-id'),
        'old-refresh',
        expiredTime: DateTime(2099),
      );
      final newToken = TokenOIDC(
        'new-access',
        TokenId('new-id'),
        'new-refresh',
        expiredTime: DateTime(2099),
      );

      await manager.persistOneTokenOidc(oldToken);
      await manager.persistOneTokenOidc(newToken);

      final allItems = await cacheClient.getAll();
      expect(allItems.length, 1,
          reason: 'stale token must be pruned after persist');

      final result = await manager.getTokenOidc(newToken.tokenIdHash);
      expect(result.token, newToken.token);
    });
  });
}
