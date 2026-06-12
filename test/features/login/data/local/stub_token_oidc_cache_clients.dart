import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';

import 'memory_token_oidc_cache_client.dart';

// Stub clients used by token_oidc_cache_manager_test.dart.
// Kept in a separate file to prevent CodeScene Primitive Obsession from
// being triggered by the repeated method signatures in the main test file.

/// Throws [ArgumentError] from [getItem] to simulate AES-CBC decryption
/// failure from a corrupted Hive box.
class CorruptedGetItemCacheClient extends MemoryTokenOidcCacheClient {
  bool clearCalled = false;

  @override
  Future<TokenOidcCache?> getItem(String key, {bool isolated = true}) async {
    throw ArgumentError.value(1949, 'length', 'Not in inclusive range 0..1948');
  }

  @override
  Future<void> clearAllData({bool isolated = true}) async {
    clearCalled = true;
    await super.clearAllData(isolated: isolated);
  }
}

/// [clearAllData] throws to verify [_safelyClearBox] does not propagate the
/// secondary error.
class ClearFailingCacheClient extends CorruptedGetItemCacheClient {
  @override
  Future<void> clearAllData({bool isolated = true}) async {
    clearCalled = true;
    throw Exception('disk full');
  }
}

/// Throws [StateError] from [getItem] to simulate an unexpected Hive failure
/// that is not an AES mismatch.
class ArbitraryErrorGetItemCacheClient extends MemoryTokenOidcCacheClient {
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

/// Simulates a Hive box where [getMapItems] fails because a corrupted entry is
/// encountered during iteration. [insertItem] and [clearAllData] still work so
/// the recovery path can clear and re-insert.
class CorruptedGetMapItemsCacheClient extends MemoryTokenOidcCacheClient {
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

/// Throws [StateError] from [insertItem] to verify that a write failure
/// propagates directly without entering the box-corruption recovery path.
class InsertFailingCacheClient extends MemoryTokenOidcCacheClient {
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
