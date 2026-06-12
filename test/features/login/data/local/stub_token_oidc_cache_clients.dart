import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';

import 'memory_token_oidc_cache_client.dart';

// Single configurable test double for all token-cache error scenarios.
// Factory constructors encode each scenario so method-override declarations
// are written once; the constructor parameters use Object?/Exception? (not
// primitives) to keep the CodeScene Primitive Obsession ratio in check.
class StubTokenOidcCacheClient extends MemoryTokenOidcCacheClient {
  bool clearCalled = false;

  final Object? _getItemError;
  final Object? _getMapItemsError;
  final Object? _insertItemError;
  final Exception? _clearError;
  final bool _insertItemFailAfterClear;

  StubTokenOidcCacheClient._({
    Object? getItemError,
    Object? getMapItemsError,
    Object? insertItemError,
    Exception? clearError,
    bool insertItemFailAfterClear = false,
  })  : _getItemError = getItemError,
        _getMapItemsError = getMapItemsError,
        _insertItemError = insertItemError,
        _clearError = clearError,
        _insertItemFailAfterClear = insertItemFailAfterClear;

  factory StubTokenOidcCacheClient.withCorruptedGetItem() =>
      StubTokenOidcCacheClient._(
        getItemError: ArgumentError.value(1949, 'length', 'Not in inclusive range 0..1948'),
      );

  factory StubTokenOidcCacheClient.withArbitraryGetItemError() =>
      StubTokenOidcCacheClient._(
        getItemError: StateError('unexpected internal Hive failure'),
      );

  factory StubTokenOidcCacheClient.withClearFailing() =>
      StubTokenOidcCacheClient._(
        getItemError: ArgumentError.value(1949, 'length', 'Not in inclusive range 0..1948'),
        clearError: Exception('disk full'),
      );

  factory StubTokenOidcCacheClient.withCorruptedGetMapItems() =>
      StubTokenOidcCacheClient._(
        getMapItemsError: ArgumentError.value(1901, 'length', 'Not in inclusive range 0..1900'),
      );

  factory StubTokenOidcCacheClient.withInsertFailing() =>
      StubTokenOidcCacheClient._(
        insertItemError: StateError('disk full'),
      );

  factory StubTokenOidcCacheClient.withCorruptedGetMapItemsAndReInsertFailing() =>
      StubTokenOidcCacheClient._(
        getMapItemsError: ArgumentError.value(1901, 'length', 'Not in inclusive range 0..1900'),
        insertItemFailAfterClear: true,
      );

  @override
  Future<TokenOidcCache?> getItem(String key, {bool isolated = true}) async {
    if (_getItemError != null) throw _getItemError;
    return super.getItem(key, isolated: isolated);
  }

  @override
  Future<Map<String, TokenOidcCache>> getMapItems({bool isolated = true}) async {
    if (_getMapItemsError != null) throw _getMapItemsError;
    return super.getMapItems(isolated: isolated);
  }

  @override
  Future<void> insertItem(
    String key,
    TokenOidcCache newObject, {
    bool isolated = true,
  }) async {
    if (_insertItemError != null) throw _insertItemError;
    if (_insertItemFailAfterClear && clearCalled) throw StateError('disk full after clear');
    await super.insertItem(key, newObject, isolated: isolated);
  }

  @override
  Future<void> clearAllData({bool isolated = true}) async {
    clearCalled = true;
    if (_clearError != null) throw _clearError;
    await super.clearAllData(isolated: isolated);
  }
}
