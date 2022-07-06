import 'package:core/utils/app_logger.dart';
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/composer/data/model/composer_cache.dart';

class ComposerCacheClient extends HiveCacheClient<ComposerCache> {

  @override
  String get tableName => "ComposerCache";

  @override
  Future<void> clearAllData() {
    return Future.sync(() async {
      final boxComposer = await openBox();
      return boxComposer.clear();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxComposer = await openBox();
      return boxComposer.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteMultipleItem(List<String> listKey) {
    return Future.sync(() async {
      final boxComposer = await openBox();
      return boxComposer.deleteAll(listKey);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<ComposerCache>> getAll() {
    return Future.sync(() async {
      final boxComposer = await openBox();
      return boxComposer.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<ComposerCache?> getItem(String key) {
    return Future.sync(() async {
      final boxComposer = await openBox();
      return boxComposer.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertItem(String key, ComposerCache newObject) {
    log('ComposerCacheClient::insertItem(): $key: $newObject');
    return Future.sync(() async {
      final boxComposer = await openBox();
      return boxComposer.put(key, newObject);
    }).catchError((error) {
      log('ComposerCacheClient::insertItem(): $error');
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(Map<String, ComposerCache> mapObject) {
    return Future.sync(() async {
      final boxComposer = await openBox();
      return boxComposer.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> isExistItem(String key) {
    return Future.sync(() async {
      final boxComposer = await openBox();
      return boxComposer.containsKey(key);
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
  Future<Box<ComposerCache>> openBox() async {
    if (Hive.isBoxOpen(tableName)) {
      return Hive.box<ComposerCache>(tableName);
    }
    return Hive.openBox<ComposerCache>(tableName);
  }

  @override
  Future<void> updateItem(String key, ComposerCache newObject) {
    return Future.sync(() async {
      final boxComposer = await openBox();
      return boxComposer.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(Map<String, ComposerCache> mapObject) {
    return Future.sync(() async {
      final boxComposer = await openBox();
      return boxComposer.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }
}