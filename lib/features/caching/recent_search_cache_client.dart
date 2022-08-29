
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/recent_search_cache.dart';

class RecentSearchCacheClient extends HiveCacheClient<RecentSearchCache> {

  @override
  String get tableName => 'RecentSearchCache';

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
  Future<List<RecentSearchCache>> getAll() {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<RecentSearchCache?> getItem(String key) {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertItem(String key, RecentSearchCache newObject) {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(Map<String, RecentSearchCache> mapObject) {
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
  Future<Box<RecentSearchCache>> openBox() async {
    if (Hive.isBoxOpen(tableName)) {
      return Hive.box<RecentSearchCache>(tableName);
    }
    return Hive.openBox<RecentSearchCache>(tableName);
  }

  @override
  Future<void> updateItem(String key, RecentSearchCache newObject) {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(Map<String, RecentSearchCache> mapObject) {
    return Future.sync(() async {
      final boxRecent = await openBox();
      return boxRecent.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteWhere(bool Function(RecentSearchCache data) validate) {
    throw UnimplementedError();
  }
}