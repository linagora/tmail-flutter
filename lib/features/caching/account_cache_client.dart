import 'package:core/utils/app_logger.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/account_cache.dart';

class AccountCacheClient extends HiveCacheClient<AccountCache> {

  @override
  String get tableName => "AccountCache";

  @override
  Future<void> clearAllData() {
    return Future.sync(() async {
      final boxToken = await openBox();
      boxToken.clear();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxToken = await openBox();
      return boxToken.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteMultipleItem(List<String> listKey) {
    return Future.sync(() async {
      final boxToken = await openBox();
      return boxToken.deleteAll(listKey);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<AccountCache>> getAll() {
    return Future.sync(() async {
      final boxToken = await openBox();
      return boxToken.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<AccountCache?> getItem(String key) {
    return Future.sync(() async {
      final boxToken = await openBox();
      return boxToken.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertItem(String key, AccountCache newObject) {
    log('AccountCacheClient::insertItem(): $key: $newObject');
    return Future.sync(() async {
      final boxToken = await openBox();
      boxToken.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(Map<String, AccountCache> mapObject) {
    return Future.sync(() async {
      final boxToken = await openBox();
      boxToken.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> isExistItem(String key) {
    return Future.sync(() async {
      final boxToken = await openBox();
      return boxToken.containsKey(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> isExistTable() {
    return Future.sync(() async {
      return await Hive.boxExists(tableName);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<Box<AccountCache>> openBox() {
    return Future.sync(() async {
      if (Hive.isBoxOpen(tableName)) {
        return Hive.box<AccountCache>(tableName);
      }
      return await Hive.openBox<AccountCache>(tableName);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateItem(String key, AccountCache newObject) {
    return Future.sync(() async {
      final boxToken = await openBox();
      boxToken.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(Map<String, AccountCache> mapObject) {
    return Future.sync(() async {
      final boxToken = await openBox();
      boxToken.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

}