
import 'dart:typed_data';

import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';

abstract class HiveCacheClient<T> {

  String get tableName;

  bool get encryption => false;

  Future<Uint8List?> _getEncryptionKey() => HiveCacheConfig.getEncryptionKey();

  Future<Box<T>> openBox() async {
    if (Hive.isBoxOpen(tableName)) {
      return Hive.box<T>(tableName);
    } else {
      return Hive.openBox<T>(tableName);
    }
  }

  Future<Box<T>> openBoxEncryption() async {
    final encryptionKey = await _getEncryptionKey();
    if (Hive.isBoxOpen(tableName)) {
      return Hive.box<T>(tableName);
    } else {
      return Hive.openBox<T>(
          tableName,
          encryptionCipher: encryptionKey != null
              ? HiveAesCipher(encryptionKey)
              : null);
    }
  }

  Future<void> insertItem(String key, T newObject) {
    return Future.sync(() async {
      final boxItem = encryption
          ? await openBoxEncryption()
          : await openBox();
      return boxItem.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> insertMultipleItem(Map<String, T> mapObject) {
    return Future.sync(() async {
      final boxItem = encryption
          ? await openBoxEncryption()
          : await openBox();
      return boxItem.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  Future<T?> getItem(String key) {
    return Future.sync(() async {
      final boxItem = encryption
          ? await openBoxEncryption()
          : await openBox();
      return boxItem.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<T>> getAll() {
    return Future.sync(() async {
      final boxItem = encryption
          ? await openBoxEncryption()
          : await openBox();
      return boxItem.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> updateItem(String key, T newObject) {
    return Future.sync(() async {
      final boxItem = encryption
          ? await openBoxEncryption()
          : await openBox();
      return boxItem.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> updateMultipleItem(Map<String, T> mapObject) {
    return Future.sync(() async {
      final boxItem = encryption
          ? await openBoxEncryption()
          : await openBox();
      return boxItem.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxItem = encryption
          ? await openBoxEncryption()
          : await openBox();
      return boxItem.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> deleteMultipleItem(List<String> listKey) {
    return Future.sync(() async {
      final boxItem = encryption
          ? await openBoxEncryption()
          : await openBox();
      return boxItem.deleteAll(listKey);
    }).catchError((error) {
      throw error;
    });
  }

  Future<bool> isExistItem(String key) {
    return Future.sync(() async {
      final boxItem = encryption
          ? await openBoxEncryption()
          : await openBox();
      return boxItem.containsKey(key);
    }).catchError((error) {
      throw error;
    });
  }

  Future<bool> isExistTable() {
    return Future.sync(() async {
      return Hive.boxExists(tableName);
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> deleteBox() {
    return Hive.deleteBoxFromDisk(tableName);
  }

  Future<void> clearAllData() {
    return Future.sync(() async {
      final boxItem = encryption
          ? await openBoxEncryption()
          : await openBox();
      return boxItem.clear();
    }).catchError((error) {
      throw error;
    });
  }
}