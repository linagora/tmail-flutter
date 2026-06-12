import 'package:flutter_test/flutter_test.dart';
import 'package:model/oidc/token_id.dart';
import 'package:model/oidc/token_oidc.dart';
import 'package:tmail_ui_user/features/login/data/extensions/token_oidc_extension.dart';
import 'package:tmail_ui_user/features/login/data/local/token_oidc_cache_manager.dart';
import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';
import 'package:tmail_ui_user/features/login/domain/exceptions/authentication_exception.dart';

import 'memory_token_oidc_cache_client.dart';

/// A cache client that throws [ArgumentError] from [getItem] to simulate
/// AES-CBC decryption failure from a corrupted Hive box.
class _CorruptedTokenOidcCacheClient extends MemoryTokenOidcCacheClient {
  bool clearCalled = false;

  @override
  Future<TokenOidcCache?> getItem(String key, {bool isolated = true}) async {
    throw ArgumentError.value(
      1949,
      'length',
      'Not in inclusive range 0..1948',
    );
  }

  @override
  Future<void> clearAllData({bool isolated = true}) async {
    clearCalled = true;
    await super.clearAllData(isolated: isolated);
  }
}

/// A cache client whose [clearAllData] also throws, to verify [_safelyClearBox]
/// does not propagate the secondary error.
class _ClearFailingTokenOidcCacheClient extends _CorruptedTokenOidcCacheClient {
  @override
  Future<void> clearAllData({bool isolated = true}) async {
    clearCalled = true;
    throw Exception('disk full');
  }
}

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
      final corruptedClient = _CorruptedTokenOidcCacheClient();
      final manager = TokenOidcCacheManager(corruptedClient);

      await expectLater(
        manager.getTokenOidc(tokenIdHash),
        throwsA(isA<NotFoundStoredTokenException>()),
      );
      expect(corruptedClient.clearCalled, isTrue,
          reason: 'corrupted box must be cleared to prevent repeated failures');
    });

    test('WHEN getItem throws a generic Error\n'
        'THEN clears the box and throws NotFoundStoredTokenException', () async {
      final stubbedClient = _ArbitraryErrorCacheClient();
      final stubbedManager = TokenOidcCacheManager(stubbedClient);

      await expectLater(
        stubbedManager.getTokenOidc(tokenIdHash),
        throwsA(isA<NotFoundStoredTokenException>()),
      );
      expect(stubbedClient.clearCalled, isTrue);
    });

    test('WHEN clearAllData itself throws\n'
        'THEN the secondary error is suppressed and NotFoundStoredTokenException is still thrown', () async {
      final client = _ClearFailingTokenOidcCacheClient();
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
      final client = _CorruptedGetMapItemsCacheClient();
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

    test('WHEN insertItem itself throws\n'
        'THEN exception propagates immediately without touching recovery path', () async {
      final client = _InsertFailingCacheClient();
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

/// Simulates a Hive box where toMap() fails because a corrupted entry is
/// encountered during iteration — the exact scenario seen in production when
/// cross-isolate writes leave non-block-aligned AES data. insertItem and
/// clearAllData still work so the recovery path can clear and re-insert.
class _CorruptedGetMapItemsCacheClient extends MemoryTokenOidcCacheClient {
  bool clearCalled = false;

  @override
  Future<Map<String, TokenOidcCache>> getMapItems({bool isolated = true}) async {
    throw ArgumentError.value(1901, 'length', 'Not in inclusive range 0..1900');
  }

  @override
  Future<void> clearAllData({bool isolated = true}) async {
    clearCalled = true;
    await super.clearAllData(isolated: isolated);
  }
}

class _ArbitraryErrorCacheClient extends MemoryTokenOidcCacheClient {
  bool clearCalled = false;

  @override
  Future<TokenOidcCache?> getItem(String key, {bool isolated = true}) async {
    throw StateError('unexpected internal Hive failure');
  }

  @override
  Future<void> clearAllData({bool isolated = true}) async {
    clearCalled = true;
    await super.clearAllData(isolated: isolated);
  }
}

/// Simulates a Hive box where insertItem itself fails (e.g. disk full, box
/// closed). clearAllData is tracked to verify the recovery path is NOT entered.
class _InsertFailingCacheClient extends MemoryTokenOidcCacheClient {
  bool clearCalled = false;

  @override
  Future<void> insertItem(
    String key,
    TokenOidcCache newObject, {
    bool isolated = true,
  }) async {
    throw StateError('disk full');
  }

  @override
  Future<void> clearAllData({bool isolated = true}) async {
    clearCalled = true;
    await super.clearAllData(isolated: isolated);
  }
}
