import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/clients/account_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

class MemoryAccountCacheClient implements AccountCacheClient {
  final Map<String, AccountCache> _cache = {};

  @override
  Future<void> clearAllData() {
    _cache.clear();
    return Future.value();
  }

  @override
  Future<void> clearAllDataContainKey(String nestedKey) {
    _cache.removeWhere((key, value) => key == nestedKey);
    return Future.value();
  }

  @override
  Future<void> closeBox() {
    return Future.value();
  }

  @override
  Future<void> deleteBox() {
    return Future.value();
  }

  @override
  Future<void> deleteItem(String key) {
    _cache.remove(key);
    return Future.value();
  }

  @override
  Future<void> deleteMultipleItem(List<String> listKey) {
    _cache.removeWhere((key, value) => listKey.contains(key));
    return Future.value();
  }

  @override
  bool get encryption => false;

  @override
  Future<List<AccountCache>> getAll() {
    return Future.value(_cache.values.toList());
  }

  @override
  Future<AccountCache?> getItem(String key) {
    return Future.value(_cache[key]);
  }

  @override
  Future<List<AccountCache>> getListByNestedKey(String nestedKey) {
    return Future.value(
        _cache.values.where((account) => account.id == nestedKey).toList());
  }

  @override
  Future<List<AccountCache>> getValuesByListKey(List<String> listKeys) {
    return Future.value(_cache.values
        .where((account) => listKeys.contains(account.id))
        .toList());
  }

  @override
  Future<void> insertItem(String key, AccountCache newObject) {
    _cache[key] = newObject;
    return Future.value();
  }

  @override
  Future<void> insertMultipleItem(Map<String, AccountCache> mapObject) {
    _cache.addAll(mapObject);
    return Future.value();
  }

  @override
  Future<bool> isExistItem(String key) {
    return Future.value(_cache.containsKey(key));
  }

  @override
  Future<Box<AccountCache>> openBox() {
    throw UnimplementedError();
  }

  @override
  Future<Box<AccountCache>> openBoxEncryption() {
    throw UnimplementedError();
  }

  @override
  String get tableName => 'AccountCache';

  @override
  Future<void> updateItem(String key, AccountCache newObject) {
    _cache[key] = newObject;
    return Future.value();
  }

  @override
  Future<void> updateMultipleItem(Map<String, AccountCache> mapObject) {
    _cache.addAll(mapObject);
    return Future.value();
  }
}
