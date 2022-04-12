
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/state_cache.dart';

class StateCacheClient extends HiveCacheClient<StateCache> {

  @override
  String get tableName => 'StateCache';

  @override
  Future<Box<StateCache>> openBox() {
    return Future.sync(() async {
      if (Hive.isBoxOpen(tableName)) {
        return Hive.box<StateCache>(tableName);
      }
      return await Hive.openBox<StateCache>(tableName);
    }).catchError((error) {
      throw error;
    });
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
  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxState = await openBox();
      return boxState.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<StateCache?> getItem(String key) {
    return Future.sync(() async {
      final boxState = await openBox();
      return boxState.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<StateCache>> getAll() {
    return Future.sync(() async {
      final boxState = await openBox();
      return boxState.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertItem(String key, StateCache newObject) {
    return Future.sync(() async {
      final boxState = await openBox();
      boxState.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(Map<String, StateCache> mapObject) {
    return Future.sync(() async {
      final boxState = await openBox();
      boxState.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateItem(String key, StateCache newObject) {
    return Future.sync(() async {
      final boxState = await openBox();
      boxState.put(key, newObject);
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
  Future<void> deleteMultipleItem(List<String> listKey) {
    return Future.sync(() async {
      final boxState = await openBox();
      boxState.deleteAll(listKey);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(Map<String, StateCache> mapObject) {
    return Future.sync(() async {
      final boxState = await openBox();
      boxState.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> clearAllData() {
    return Future.sync(() async {
      final boxState = await openBox();
      boxState.clear();
    }).catchError((error) {
      throw error;
    });
  }
}