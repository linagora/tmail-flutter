import 'dart:typed_data';

import 'package:core/presentation/extensions/map_extensions.dart';
import 'package:core/utils/app_logger.dart';
import 'package:hive_ce/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_config.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';

abstract class HiveCacheClient<T> {

  String get tableName;

  bool get encryption => false;

  Future<Uint8List?> _getEncryptionKey() => HiveCacheConfig.instance.getEncryptionKey();

  Future<IsolatedBox<T>> openBox() async {
    if (IsolatedHive.isBoxOpen(tableName)) {
      return IsolatedHive.box<T>(tableName);
    } else {
      return IsolatedHive.openBox<T>(tableName);
    }
  }

  Future<IsolatedBox<T>> openBoxEncryption() async {
    final encryptionKey = await _getEncryptionKey();
    if (IsolatedHive.isBoxOpen(tableName)) {
      return IsolatedHive.box<T>(tableName);
    } else {
      return IsolatedHive.openBox<T>(tableName,
          encryptionCipher:
              encryptionKey != null ? HiveAesCipher(encryptionKey) : null);
    }
  }

  Future<void> insertItem(String key, T newObject) {
    log('$runtimeType::insertItem:encryption: $encryption - key = $key');
    return Future.sync(() async {
      final boxItem = encryption ? await openBoxEncryption() : await openBox();
      return boxItem.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> insertMultipleItem(Map<String, T> mapObject) {
    return Future.sync(() async {
      final boxItem = encryption ? await openBoxEncryption() : await openBox();
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
      final boxItem = encryption ? await openBoxEncryption() : await openBox();
      final items = await boxItem.values;
      return items.toList();
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<T>> getListByNestedKey(String nestedKey) {
    return Future.sync(() async {
      final boxItem = encryption ? await openBoxEncryption() : await openBox();
      final mapItems = await boxItem.toMap();
      final listItem = mapItems
        .where((key, value) => _matchedNestedKey(key, nestedKey))
        .values
        .toList();
      log('$runtimeType::getListByNestedKey:listItem: ${listItem.length}');
      return listItem;
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<T>> getValuesByListKey(List<String> listKeys) {
    return Future.sync(() async {
      final boxItem = encryption ? await openBoxEncryption() : await openBox();
      final mapItems = await boxItem.toMap();
      return mapItems
        .where((key, value) => listKeys.contains(key))
        .values
        .toList();
    }).catchError((error) {
      throw error;
    });
  }

  bool _matchedNestedKey(String key, String nestedKey) {
    final decodedKey = CacheUtils.decodeKey(key);
    final decodedNestedKey = CacheUtils.decodeKey(nestedKey);
    return decodedKey.contains(decodedNestedKey);
  }

  Future<void> updateItem(String key, T newObject) {
    return Future.sync(() async {
      final boxItem = encryption ? await openBoxEncryption() : await openBox();
      return boxItem.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> updateMultipleItem(Map<String, T> mapObject) {
    return Future.sync(() async {
      final boxItem = encryption ? await openBoxEncryption() : await openBox();
      return boxItem.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxItem = encryption ? await openBoxEncryption() : await openBox();
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

  Future<void> deleteBox() {
    return IsolatedHive.deleteBoxFromDisk(tableName);
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

  Future<void> clearAllDataContainKey(String nestedKey) {
    return Future.sync(() async {
      final boxItem = encryption ? await openBoxEncryption() : await openBox();
      final mapItems = await boxItem.toMap();
      final listKeys = mapItems
        .where((key, value) => _matchedNestedKey(key, nestedKey))
        .keys;
      log('$runtimeType::clearAllDataContainKey:listKeys: ${listKeys.length}');
      return boxItem.deleteAll(listKeys);
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> closeBox() async {
    if (IsolatedHive.isBoxOpen(tableName)) {
      await IsolatedHive.box<T>(tableName).close();
    }
    return Future.value();
  }
}