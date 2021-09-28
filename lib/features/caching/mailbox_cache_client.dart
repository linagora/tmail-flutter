
import 'package:hive/hive.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/caching/config/cache_client.dart';

class MailboxCacheClient extends CacheClient<MailboxCache> {

  @override
  String get tableName => 'MailboxCache';

  @override
  Future<Box<MailboxCache>> openTable() {
    return Future.sync(() async {
      if (Hive.isBoxOpen(tableName)) {
        return Hive.box<MailboxCache>(tableName);
      }
      return await Hive.openBox<MailboxCache>(tableName);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> isExistItem(String key) {
    return Future.sync(() async {
      final boxMailbox = await openTable();
      return boxMailbox.containsKey(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxMailbox = await openTable();
      return boxMailbox.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<MailboxCache?> getItem(String key) {
    return Future.sync(() async {
      final boxMailbox = await openTable();
      return boxMailbox.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<MailboxCache>> getListItem() {
    return Future.sync(() async {
      final boxMailbox = await openTable();
      return boxMailbox.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertItem(String key, MailboxCache newObject) {
    return Future.sync(() async {
      final boxMailbox = await openTable();
      boxMailbox.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(Map<String, MailboxCache> mapObject) {
    return Future.sync(() async {
      final boxMailbox = await openTable();
      boxMailbox.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateItem(String key, MailboxCache newObject) {
    return Future.sync(() async {
      final boxMailbox = await openTable();
      boxMailbox.put(key, newObject);
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
      final boxMailbox = await openTable();
      return boxMailbox.deleteAll(listKey);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(Map<String, MailboxCache> mapObject) {
    return Future.sync(() async {
      final boxMailbox = await openTable();
      boxMailbox.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }
}