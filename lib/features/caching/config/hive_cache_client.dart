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

  Future<IsolatedBox<T>> openIsolatedBox() async {
    if (IsolatedHive.isBoxOpen(tableName)) {
      return IsolatedHive.box<T>(tableName);
    } else {
      if (encryption) {
        final encryptionKey = await _getEncryptionKey();
        return IsolatedHive.openBox<T>(
          tableName,
          encryptionCipher:
              encryptionKey != null ? HiveAesCipher(encryptionKey) : null,
        );
      } else {
        return IsolatedHive.openBox<T>(tableName);
      }
    }
  }

  Future<Box<T>> openBox() async {
    if (Hive.isBoxOpen(tableName)) {
      return Hive.box<T>(tableName);
    } else {
      if (encryption) {
        final encryptionKey = await _getEncryptionKey();
        return Hive.openBox<T>(
          tableName,
          encryptionCipher:
              encryptionKey != null ? HiveAesCipher(encryptionKey) : null,
        );
      } else {
        return Hive.openBox<T>(tableName);
      }
    }
  }

  Future<void> insertItem(
    String key,
    T newObject, {
    bool isolated = true,
  }) {
    log('$runtimeType::insertItem:encryption: $encryption - key = $key - isolated = $isolated');
    return Future.sync(() async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.put(key, newObject);
      } else {
        final boxItem = await openBox();
        return boxItem.put(key, newObject);
      }
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> insertMultipleItem(
    Map<String, T> mapObject, {
    bool isolated = true,
  }) {
    return Future.sync(() async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.putAll(mapObject);
      } else {
        final boxItem = await openBox();
        return boxItem.putAll(mapObject);
      }
    }).catchError((error) {
      throw error;
    });
  }

  Future<T?> getItem(
    String key, {
    bool isolated = true,
  }) {
    return Future.sync(() async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.get(key);
      } else {
        final boxItem = await openBox();
        return boxItem.get(key);
      }
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<T>> getAll({bool isolated = true}) {
    return Future.sync(() async {
      Iterable<T> items;

      if (isolated) {
        final boxItem = await openIsolatedBox();
         items = await boxItem.values;
      } else {
        final boxItem = await openBox();
         items = boxItem.values;
      }
      log('$runtimeType::getAll: Length of items is ${items.length}');
      return items.toList();
    }).catchError((error) {
      throw error;
    });
  }

  Future<Map<String, T>> getMapItems({bool isolated = true}) {
    return Future.sync(() async {
      late Map<dynamic, T> mapItems;

      if (isolated) {
        final boxItem = await openIsolatedBox();
        mapItems = await boxItem.toMap();
      } else {
        final boxItem = await openBox();
        mapItems = boxItem.toMap();
      }
      log('$runtimeType::getMapItems: Length of mapItems is ${mapItems.length}');
      return mapItems.map((key, value) => MapEntry(key.toString(), value));
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<T>> getListByNestedKey(
    String nestedKey, {
    bool isolated = true,
  }) {
    return Future.sync(() async {
      late Map<dynamic, T> mapItems;

      if (isolated) {
        final boxItem = await openIsolatedBox();
        mapItems = await boxItem.toMap();
      } else {
        final boxItem = await openBox();
        mapItems = boxItem.toMap();
      }

      final listItem = mapItems
        .where((key, value) => _matchedNestedKey(key, nestedKey))
        .values
        .toList();
      log('$runtimeType::getListByNestedKey: Length of listItem is ${listItem.length}');
      return listItem;
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<T>> getValuesByListKey(
    List<String> listKeys, {
    bool isolated = true,
  }) {
    return Future.sync(() async {
      late Map<dynamic, T> mapItems;

      if (isolated) {
        final boxItem = await openIsolatedBox();
        mapItems = await boxItem.toMap();
      } else {
        final boxItem = await openBox();
        mapItems = boxItem.toMap();
      }

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

  Future<void> updateItem(
    String key,
    T newObject, {
    bool isolated = true,
  }) {
    return Future.sync(() async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.put(key, newObject);
      } else {
        final boxItem = await openBox();
        return boxItem.put(key, newObject);
      }
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> updateMultipleItem(
    Map<String, T> mapObject, {
    bool isolated = true,
  }) {
    return Future.sync(() async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.putAll(mapObject);
      } else {
        final boxItem = await openBox();
        return boxItem.putAll(mapObject);
      }
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> deleteItem(
    String key, {
    bool isolated = true,
  }) {
    return Future.sync(() async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.delete(key);
      } else {
        final boxItem = await openBox();
        return boxItem.delete(key);
      }
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> deleteMultipleItem(
    List<String> listKey, {
    bool isolated = true,
  }) {
    return Future.sync(() async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.deleteAll(listKey);
      } else {
        final boxItem = await openBox();
        return boxItem.deleteAll(listKey);
      }
    }).catchError((error) {
      throw error;
    });
  }

  Future<bool> isExistItem(
    String key, {
    bool isolated = true,
  }) {
    return Future.sync(() async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.containsKey(key);
      } else {
        final boxItem = await openBox();
        return boxItem.containsKey(key);
      }
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> deleteBox({bool isolated = true}) {
    if (isolated) {
      return IsolatedHive.deleteBoxFromDisk(tableName);
    } else {
      return Hive.deleteBoxFromDisk(tableName);
    }
  }

  Future<void> clearAllData({bool isolated = true}) {
    return Future.sync(() async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.clear();
      } else {
        final boxItem = await openBox();
        return boxItem.clear();
      }
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> clearAllDataContainKey(
    String nestedKey, {
    bool isolated = true,
  }) {
    return Future.sync(() async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        final mapItems = await boxItem.toMap();
        final listKeys = mapItems
            .where((key, value) => _matchedNestedKey(key, nestedKey))
            .keys;
        log('$runtimeType::clearAllDataContainKey: Length of keys is ${listKeys.length}');
        return boxItem.deleteAll(listKeys);
      } else {
        final boxItem = await openBox();
        final listKeys = boxItem.toMap()
            .where((key, value) => _matchedNestedKey(key, nestedKey))
            .keys;
        log('$runtimeType::clearAllDataContainKey: Length of keys is ${listKeys.length}');
        return boxItem.deleteAll(listKeys);
      }
    }).catchError((error) {
      throw error;
    });
  }

  Future<void> closeBox({bool isolated = true}) async {
    if (isolated) {
      if (IsolatedHive.isBoxOpen(tableName)) {
        await IsolatedHive.box<T>(tableName).close();
      }
    } else {
      if (Hive.isBoxOpen(tableName)) {
        await Hive.box<T>(tableName).close();
      }
    }
  }
}
