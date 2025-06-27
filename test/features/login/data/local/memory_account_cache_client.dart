import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/clients/account_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

class MemoryAccountCacheClient implements AccountCacheClient {
  final Map<String, AccountCache> _cache = {};

  @override
  Future<void> clearAllData({bool isolated = false}) {
    _cache.clear();
    return Future.value();
  }

  @override
  Future<void> clearAllDataContainKey(
    String nestedKey, {
    bool isolated = false,
  }) {
    _cache.removeWhere((key, value) => key == nestedKey);
    return Future.value();
  }

  @override
  Future<void> closeBox({bool isolated = false}) {
    return Future.value();
  }

  @override
  Future<void> deleteBox({bool isolated = false}) {
    return Future.value();
  }

  @override
  Future<void> deleteItem(String key, {bool isolated = false}) {
    _cache.remove(key);
    return Future.value();
  }

  @override
  Future<void> deleteMultipleItem(List<String> listKey,
      {bool isolated = false}) {
    _cache.removeWhere((key, value) => listKey.contains(key));
    return Future.value();
  }

  @override
  bool get encryption => false;

  @override
  Future<List<AccountCache>> getAll({bool isolated = false}) {
    return Future.value(_cache.values.toList());
  }

  @override
  Future<AccountCache?> getItem(String key, {bool isolated = false}) {
    return Future.value(_cache[key]);
  }

  @override
  Future<List<AccountCache>> getListByNestedKey(
    String nestedKey, {
    bool isolated = false,
  }) {
    return Future.value(
        _cache.values.where((account) => account.id == nestedKey).toList());
  }

  @override
  Future<List<AccountCache>> getValuesByListKey(
    List<String> listKeys, {
    bool isolated = false,
  }) {
    return Future.value(_cache.values
        .where((account) => listKeys.contains(account.id))
        .toList());
  }

  @override
  Future<void> insertItem(
    String key,
    AccountCache newObject, {
    bool isolated = false,
  }) {
    _cache[key] = newObject;
    return Future.value();
  }

  @override
  Future<void> insertMultipleItem(
    Map<String, AccountCache> mapObject, {
    bool isolated = false,
  }) {
    _cache.addAll(mapObject);
    return Future.value();
  }

  @override
  Future<bool> isExistItem(String key, {bool isolated = false}) {
    return Future.value(_cache.containsKey(key));
  }

  @override
  Future<Box<AccountCache>> openBox() {
    throw UnimplementedError();
  }

  @override
  String get tableName => 'AccountCache';

  @override
  Future<void> updateItem(
    String key,
    AccountCache newObject, {
    bool isolated = false,
  }) {
    _cache[key] = newObject;
    return Future.value();
  }

  @override
  Future<void> updateMultipleItem(
    Map<String, AccountCache> mapObject, {
    bool isolated = false,
  }) {
    _cache.addAll(mapObject);
    return Future.value();
  }

  @override
  Future<IsolatedBox<AccountCache>> openIsolatedBox() {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, AccountCache>> getMapItems({bool isolated = true}) {
    throw UnimplementedError();
  }
}
