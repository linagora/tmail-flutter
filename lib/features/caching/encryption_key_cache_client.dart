import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/encryption_key_cache.dart';

class EncryptionKeyCacheClient extends HiveCacheClient<EncryptionKeyCache> {

  @override
  String get tableName => "EncryptionKeyCache";

  @override
  Future<void> clearAllData() {
    return Future.sync(() async {
      final boxEncryptionKey = await openBox();
      return boxEncryptionKey.clear();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxEncryptionKey = await openBox();
      return boxEncryptionKey.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteMultipleItem(List<String> listKey) {
    return Future.sync(() async {
      final boxEncryptionKey = await openBox();
      return boxEncryptionKey.deleteAll(listKey);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<EncryptionKeyCache>> getAll() {
    return Future.sync(() async {
      final boxEncryptionKey = await openBox();
      return boxEncryptionKey.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<EncryptionKeyCache?> getItem(String key) {
    return Future.sync(() async {
      final boxEncryptionKey = await openBox();
      return boxEncryptionKey.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertItem(String key, EncryptionKeyCache newObject) {
    return Future.sync(() async {
      final boxEncryptionKey = await openBox();
      return boxEncryptionKey.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(Map<String, EncryptionKeyCache> mapObject) {
    return Future.sync(() async {
      final boxEncryptionKey = await openBox();
      return boxEncryptionKey.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> isExistItem(String key) {
    return Future.sync(() async {
      final boxEncryptionKey = await openBox();
      return boxEncryptionKey.containsKey(key);
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
  Future<Box<EncryptionKeyCache>> openBox() async {
    if (Hive.isBoxOpen(tableName)) {
      return Hive.box<EncryptionKeyCache>(tableName);
    } else {
      return Hive.openBox<EncryptionKeyCache>(tableName);
    }
  }

  @override
  Future<void> updateItem(String key, EncryptionKeyCache newObject) {
    return Future.sync(() async {
      final boxEncryptionKey = await openBox();
      return boxEncryptionKey.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(Map<String, EncryptionKeyCache> mapObject) {
    return Future.sync(() async {
      final boxEncryptionKey = await openBox();
      return boxEncryptionKey.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

}