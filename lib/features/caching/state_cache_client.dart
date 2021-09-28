
import 'package:hive/hive.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/caching/config/cache_client.dart';

class StateCacheClient extends CacheClient<StateDao> {

  @override
  String get tableName => 'StateCache';

  @override
  Future<Box<StateDao>> openTable() {
    return Future.sync(() async {
      if (Hive.isBoxOpen(tableName)) {
        return Hive.box<StateDao>(tableName);
      }
      return await Hive.openBox<StateDao>(tableName);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> isExistItem(String key) {
    return Future.sync(() async {
      final boxState = await openTable();
      return boxState.containsKey(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxState = await openTable();
      return boxState.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<StateDao?> getItem(String key) {
    return Future.sync(() async {
      final boxState = await openTable();
      return boxState.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<StateDao>> getListItem() {
    return Future.sync(() async {
      final boxState = await openTable();
      return boxState.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertItem(String key, StateDao newObject) {
    return Future.sync(() async {
      final boxState = await openTable();
      boxState.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(Map<String, StateDao> mapObject) {
    return Future.sync(() async {
      final boxState = await openTable();
      boxState.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateItem(String key, StateDao newObject) {
    return Future.sync(() async {
      final boxState = await openTable();
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
      final boxState = await openTable();
      boxState.deleteAll(listKey);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(Map<String, StateDao> mapObject) {
    return Future.sync(() async {
      final boxState = await openTable();
      boxState.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }
}