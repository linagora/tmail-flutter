import 'package:core/utils/app_logger.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/thread/data/model/recent_search_hive_cache.dart';

class RecentSearchClient extends HiveCacheClient<RecentSearchHiveCache> {

  @override
  String get tableName => 'RecentSearchCache';

  Future<List<RecentSearchHiveCache>> storeRecentSeachToHive(
      String keyword) async {
    final boxRecentSearch = await openBox();
    if (keyword.isNotEmpty) {
      final value =
          RecentSearchHiveCache(value: keyword, searchedAt: DateTime.now());

      final listRecentSearch = await getAll();

      listRecentSearch.asMap().forEach((index, recentSearch) async {
          if (recentSearch.value == keyword) {
            await boxRecentSearch.deleteAt(index);
          }
      });

      if (listRecentSearch.length == 10) {
        await boxRecentSearch.deleteAt(0);
      }

      await boxRecentSearch.add(value);
   
      return await getAll();
    }
    return [];
  }

  Future<List<RecentSearchHiveCache>> getRecentSearchs(String keyword) async {
    final allRecentSearch = await getAll();
    allRecentSearch.removeWhere((item) => item.value != null && !item.value!.contains(keyword));
    return allRecentSearch;
  }

  @override
  Future<Box<RecentSearchHiveCache>> openBox() {
    return Future.sync(() async {
      if (Hive.isBoxOpen(tableName)) {
        return Hive.box<RecentSearchHiveCache>(tableName);
      }
      return await Hive.openBox<RecentSearchHiveCache>(tableName);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> clearAllData() {
    return Future.sync(() async {
      final boxRecentSearch = await openBox();
      boxRecentSearch.clear();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxRecentSearch = await openBox();
      return boxRecentSearch.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteMultipleItem(List<String> listKey) {
    return Future.sync(() async {
      log('RecentSearchClient::deleteMultipleItem(): listKey: ${listKey.length}');
      final boxRecentSearch = await openBox();
      return boxRecentSearch.deleteAll(listKey);
    }).catchError((error) {
      log('RecentSearchClient::deleteMultipleItem(): error: $error');
      throw error;
    });
  }

  @override
  Future<List<RecentSearchHiveCache>> getAll() {
    return Future.sync(() async {
      final boxRecentSearch = await openBox();
      return boxRecentSearch.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<RecentSearchHiveCache?> getItem(String key) {
    return Future.sync(() async {
      final boxRecentSearch = await openBox();
      return boxRecentSearch.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertItem(String key, RecentSearchHiveCache newObject) {
    return Future.sync(() async {
      final boxRecentSearch = await openBox();
      boxRecentSearch.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(
      Map<String, RecentSearchHiveCache> mapObject) {
    return Future.sync(() async {
      final boxRecentSearch = await openBox();
      boxRecentSearch.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> isExistItem(String key) {
    return Future.sync(() async {
      final boxRecentSearch = await openBox();
      return boxRecentSearch.containsKey(key);
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
  Future<void> updateItem(String key, RecentSearchHiveCache newObject) {
    return Future.sync(() async {
      final boxRecentSearch = await openBox();
      boxRecentSearch.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(
      Map<String, RecentSearchHiveCache> mapObject) {
    return Future.sync(() async {
      final boxRecentSearch = await openBox();
      boxRecentSearch.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }
}
