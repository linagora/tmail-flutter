import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/clients/token_oidc_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/token_oidc_cache.dart';

class MemoryTokenOidcCacheClient implements TokenOidcCacheClient {
  final Map<String, TokenOidcCache> _cache = {};

  @override
  String get tableName => 'TokenOidcCache';

  @override
  bool get encryption => false;

  @override
  Future<TokenOidcCache?> getItem(String key, {bool isolated = true}) async {
    return _cache[key];
  }

  @override
  Future<void> insertItem(
    String key,
    TokenOidcCache newObject, {
    bool isolated = true,
  }) async {
    _cache[key] = newObject;
  }

  @override
  Future<void> insertMultipleItem(
    Map<String, TokenOidcCache> mapObject, {
    bool isolated = true,
  }) async {
    _cache.addAll(mapObject);
  }

  @override
  Future<void> updateItem(
    String key,
    TokenOidcCache newObject, {
    bool isolated = true,
  }) async {
    _cache[key] = newObject;
  }

  @override
  Future<void> updateMultipleItem(
    Map<String, TokenOidcCache> mapObject, {
    bool isolated = true,
  }) async {
    _cache.addAll(mapObject);
  }

  @override
  Future<void> deleteItem(String key, {bool isolated = true}) async {
    _cache.remove(key);
  }

  @override
  Future<void> deleteMultipleItem(List<String> listKey, {bool isolated = true}) async {
    _cache.removeWhere((key, _) => listKey.contains(key));
  }

  @override
  Future<void> clearAllData({bool isolated = true}) async {
    _cache.clear();
  }

  @override
  Future<void> clearAllDataContainKey(String nestedKey, {bool isolated = true}) async {
    _cache.removeWhere((key, _) => key.contains(nestedKey));
  }

  @override
  Future<List<TokenOidcCache>> getAll({bool isolated = true}) async {
    return _cache.values.toList();
  }

  @override
  Future<Map<String, TokenOidcCache>> getMapItems({bool isolated = true}) async {
    return Map.from(_cache);
  }

  @override
  Future<List<TokenOidcCache>> getListByNestedKey(
    String nestedKey, {
    bool isolated = true,
  }) async {
    return _cache.values.where((v) => v.tokenId.contains(nestedKey)).toList();
  }

  @override
  Future<List<TokenOidcCache>> getValuesByListKey(
    List<String> listKeys, {
    bool isolated = true,
  }) async {
    return _cache.entries
        .where((e) => listKeys.contains(e.key))
        .map((e) => e.value)
        .toList();
  }

  @override
  Future<bool> isExistItem(String key, {bool isolated = true}) async {
    return _cache.containsKey(key);
  }

  @override
  Future<void> closeBox({bool isolated = true}) async {}

  @override
  Future<void> deleteBox({bool isolated = true}) async {
    _cache.clear();
  }

  @override
  Future<Box<TokenOidcCache>> openBox() {
    throw UnimplementedError();
  }

  @override
  Future<IsolatedBox<TokenOidcCache>> openIsolatedBox() {
    throw UnimplementedError();
  }
}
