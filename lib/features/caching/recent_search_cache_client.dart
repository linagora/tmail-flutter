
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/recent_search_cache.dart';

class RecentSearchCacheClient extends HiveCacheClient<RecentSearchCache> {

  @override
  String get tableName => 'RecentSearchCache';

  @override
  Future<void> clearAllData() {
    return Future.sync(() async {
      final boxState = await openBox();
      boxState.clear();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxState = await openBox();
      return boxState.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteMultipleItem(List<String> listKey) {
    return Future.sync(() async {
      final boxEmail = await openBox();
      return boxEmail.deleteAll(listKey);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<RecentSearchCache>> getAll() {
    return Future.sync(() async {
      final boxState = await openBox();
      return boxState.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<RecentSearchCache?> getItem(String key) {
    throw UnimplementedError();
  }

  @override
  Future<void> insertItem(String key, RecentSearchCache newObject) {
    return Future.sync(() async {
      final boxState = await openBox();
      boxState.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(Map<String, RecentSearchCache> mapObject) {
    throw UnimplementedError();
  }

  @override
  Future<bool> isExistItem(String key) {
    return Future.sync(() async {
      final boxState = await openBox();
      return boxState.containsKey(key);
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
  Future<Box<RecentSearchCache>> openBox() {
    return Future.sync(() async {
      if (Hive.isBoxOpen(tableName)) {
        return Hive.box<RecentSearchCache>(tableName);
      }
      return await Hive.openBox<RecentSearchCache>(tableName);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateItem(String key, RecentSearchCache newObject) {
    return Future.sync(() async {
      final boxState = await openBox();
      boxState.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(Map<String, RecentSearchCache> mapObject) {
    throw UnimplementedError();
  }
}