import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/recent_login_url_cache.dart';

class RecentLoginUrlCacheClient extends HiveCacheClient<RecentLoginUrlCache> {
  
  @override
  String get tableName => 'RecentLoginUrlCache';

  @override
  Future<void> clearAllData() {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.clear();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteMultipleItem(List<String> listKey) {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.deleteAll(listKey);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<RecentLoginUrlCache>> getAll() {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<RecentLoginUrlCache?> getItem(String key) {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertItem(String key, RecentLoginUrlCache newObject) {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(Map<String, RecentLoginUrlCache> mapObject) {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> isExistItem(String key) {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.containsKey(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> isExistTable() {
    return Future.sync(() async {
      return Hive.boxExists(tableName);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<Box<RecentLoginUrlCache>> openBox() async {
    if (Hive.isBoxOpen(tableName)) {
      return Hive.box<RecentLoginUrlCache>(tableName);
    }
    return Hive.openBox<RecentLoginUrlCache>(tableName);
  }

  @override
  Future<void> updateItem(String key, RecentLoginUrlCache newObject) {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(Map<String, RecentLoginUrlCache> mapObject) {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }
}