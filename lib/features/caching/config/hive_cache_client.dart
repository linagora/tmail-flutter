import 'dart:typed_data';

import 'package:core/presentation/extensions/map_extensions.dart';
import 'package:core/utils/app_logger.dart';
import 'package:core/utils/platform_info.dart';
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

  /// The latest recovery of each box, kept after it completes so it doubles as
  /// the token that says which box a caller started out against.
  ///
  /// Keyed on the table
  static final Map<String, Future<void>> _recoveries = {};

  /// Runs [action], retrying once if the IndexedDB connection died underneath us.
  ///
  /// Hive's web backend registers no close listener, so when a connection goes
  /// away the box stays registered as open and every later operation throws for
  /// the rest of the session — only a page reload recovers. Closing the stale box
  /// unregisters it, so re-running [action] opens a live connection instead.
  ///
  /// Every caller resolves its box *inside* [action], so the retry picks up
  /// whatever the recovery reopened.
  Future<R> _runWithRecovery<R>(bool isolated, Future<R> Function() action) async {
    final recoveryAtStart = _recoveries[tableName];
    final closeGeneration = HiveCacheConfig.instance.closeGeneration;
    try {
      return await action();
    } catch (error) {
      if (!_isRecoverableConnectionLoss(error, isolated, closeGeneration)) {
        rethrow;
      }

      logWarning(
        '$runtimeType::_runWithRecovery: reopening "$tableName" '
        '(isolated: $isolated) after a closed IndexedDB connection | $error',
      );

      if (identical(_recoveries[tableName], recoveryAtStart)) {
        await (_recoveries[tableName] = _discardStaleBox(isolated));
      } else {
        await _recoveries[tableName];
      }

      return _retryAfterRecovery(action);
    }
  }

  /// Whether [error] is a dead connection this client may reopen.
  ///
  /// [closeGeneration] is what [HiveCacheConfig] reported when the operation
  /// started, so a teardown that has run since is visible here.
  bool _isRecoverableConnectionLoss(
    Object error,
    bool isolated,
    int closeGeneration,
  ) {
    // Web-only by construction. IndexedDB is the one backend that can lose a
    // connection while Hive still holds the box
    if (!PlatformInfo.isWeb) return false;

    if (!_isClosedConnectionError(error)) return false;

    if (HiveCacheConfig.instance.closeGeneration != closeGeneration) {
      logWarning(
        '$runtimeType::_isRecoverableConnectionLoss: "$tableName" spans a '
        'deliberate close, not retrying | $error',
      );
      return false;
    }

    if (!_isBoxRegistered(isolated)) {
      // Somebody closed this box on purpose
      logWarning(
        '$runtimeType::_isRecoverableConnectionLoss: "$tableName" was closed '
        'deliberately, not reopening | $error',
      );
      return false;
    }

    return true;
  }

  /// The one retry, run against whatever [_discardStaleBox] left behind.
  Future<R> _retryAfterRecovery<R>(Future<R> Function() action) async {
    try {
      final result = await action();
      logWarning('$runtimeType::_retryAfterRecovery: "$tableName" recovered');
      return result;
    } catch (retryError, retryStackTrace) {
      logError(
        '$runtimeType::_retryAfterRecovery: "$tableName" still failing after '
        'reopen',
        exception: retryError,
        stackTrace: retryStackTrace,
      );
      rethrow;
    }
  }

  bool _isBoxRegistered(bool isolated) => isolated
      ? IsolatedHive.isBoxOpen(tableName)
      : Hive.isBoxOpen(tableName);

  bool _isClosedConnectionError(Object error) {
    final message = error.toString().toLowerCase();
    return message.contains('invalidstateerror') ||
        message.contains('connection is closing') ||
        message.contains('closed database');
  }

  Future<void> _discardStaleBox(bool isolated) async {
    try {
      await closeBox(isolated: isolated);
    } catch (e) {
      // Best-effort: the connection is already gone. What matters is that Hive
      // unregisters the box, which happens before the backend close is attempted.
      logWarning('$runtimeType::_discardStaleBox: "$tableName" close failed | $e');
    }
  }

  Future<void> insertItem(
    String key,
    T newObject, {
    bool isolated = true,
  }) {
    log('$runtimeType::insertItem:encryption: $encryption - key = $key - isolated = $isolated');
    return _runWithRecovery(isolated, () async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.put(key, newObject);
      } else {
        final boxItem = await openBox();
        return boxItem.put(key, newObject);
      }
    });
  }

  Future<void> insertMultipleItem(
    Map<String, T> mapObject, {
    bool isolated = true,
  }) {
    return _runWithRecovery(isolated, () async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.putAll(mapObject);
      } else {
        final boxItem = await openBox();
        return boxItem.putAll(mapObject);
      }
    });
  }

  Future<T?> getItem(
    String key, {
    bool isolated = true,
  }) {
    return _runWithRecovery(isolated, () async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.get(key);
      } else {
        final boxItem = await openBox();
        return boxItem.get(key);
      }
    });
  }

  Future<List<T>> getAll({bool isolated = true}) {
    return _runWithRecovery(isolated, () async {
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
    });
  }

  Future<Map<String, T>> getMapItems({bool isolated = true}) {
    return _runWithRecovery(isolated, () async {
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
    });
  }

  Future<List<T>> getListByNestedKey(
    String nestedKey, {
    bool isolated = true,
  }) {
    return _runWithRecovery(isolated, () async {
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
    });
  }

  Future<List<T>> getValuesByListKey(
    List<String> listKeys, {
    bool isolated = true,
  }) {
    return _runWithRecovery(isolated, () async {
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
    return _runWithRecovery(isolated, () async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.put(key, newObject);
      } else {
        final boxItem = await openBox();
        return boxItem.put(key, newObject);
      }
    });
  }

  Future<void> updateMultipleItem(
    Map<String, T> mapObject, {
    bool isolated = true,
  }) {
    return _runWithRecovery(isolated, () async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.putAll(mapObject);
      } else {
        final boxItem = await openBox();
        return boxItem.putAll(mapObject);
      }
    });
  }

  Future<void> deleteItem(
    String key, {
    bool isolated = true,
  }) {
    return _runWithRecovery(isolated, () async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.delete(key);
      } else {
        final boxItem = await openBox();
        return boxItem.delete(key);
      }
    });
  }

  Future<void> deleteMultipleItem(
    List<String> listKey, {
    bool isolated = true,
  }) {
    return _runWithRecovery(isolated, () async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.deleteAll(listKey);
      } else {
        final boxItem = await openBox();
        return boxItem.deleteAll(listKey);
      }
    });
  }

  Future<bool> isExistItem(
    String key, {
    bool isolated = true,
  }) {
    return _runWithRecovery(isolated, () async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        return boxItem.containsKey(key);
      } else {
        final boxItem = await openBox();
        return boxItem.containsKey(key);
      }
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
    return _runWithRecovery<void>(isolated, () async {
      if (isolated) {
        final boxItem = await openIsolatedBox();
        await boxItem.clear();
      } else {
        final boxItem = await openBox();
        await boxItem.clear();
      }
    });
  }

  Future<void> clearAllDataContainKey(
    String nestedKey, {
    bool isolated = true,
  }) {
    return _runWithRecovery(isolated, () async {
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
