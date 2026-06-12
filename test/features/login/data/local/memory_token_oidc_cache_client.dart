import 'package:tmail_ui_user/features/caching/clients/token_oidc_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';

// Extends instead of implements so only the methods needed by tests are
// explicitly declared. All other HiveCacheClient methods are inherited (and
// unreachable in tests), which keeps this file small and avoids false-positive
// CodeScene "Primitive Obsession" from re-declaring every interface method.
class MemoryTokenOidcCacheClient extends TokenOidcCacheClient {
  final Map<String, TokenOidcCache> _store = {};

  @override
  Future<TokenOidcCache?> getItem(String key, {bool isolated = true}) async =>
      _store[key];

  @override
  Future<void> insertItem(
    String key,
    TokenOidcCache newObject, {
    bool isolated = true,
  }) async =>
      _store[key] = newObject;

  @override
  Future<void> deleteMultipleItem(
    List<String> listKey, {
    bool isolated = true,
  }) async =>
      _store.removeWhere((k, _) => listKey.contains(k));

  @override
  Future<void> clearAllData({bool isolated = true}) async => _store.clear();

  @override
  Future<Map<String, TokenOidcCache>> getMapItems({bool isolated = true}) async =>
      Map.of(_store);

  @override
  Future<List<TokenOidcCache>> getAll({bool isolated = true}) async =>
      _store.values.toList();
}
