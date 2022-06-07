
import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache.dart';

class MailboxCacheClient extends HiveCacheClient<MailboxCache> {

  @override
  String get tableName => 'MailboxCache';

  @override
  Future<Box<MailboxCache>> openBox() async {
    if (Hive.isBoxOpen(tableName)) {
      return Hive.box<MailboxCache>(tableName);
    }
    return Hive.openBox<MailboxCache>(tableName);
  }

  @override
  Future<bool> isExistItem(String key) {
    return Future.sync(() async {
      final boxMailbox = await openBox();
      return boxMailbox.containsKey(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxMailbox = await openBox();
      return boxMailbox.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<MailboxCache?> getItem(String key) {
    return Future.sync(() async {
      final boxMailbox = await openBox();
      return boxMailbox.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<MailboxCache>> getAll() {
    return Future.sync(() async {
      final boxMailbox = await openBox();
      return boxMailbox.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertItem(String key, MailboxCache newObject) {
    return Future.sync(() async {
      final boxMailbox = await openBox();
      boxMailbox.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(Map<String, MailboxCache> mapObject) {
    return Future.sync(() async {
      final boxMailbox = await openBox();
      boxMailbox.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateItem(String key, MailboxCache newObject) {
    return Future.sync(() async {
      final boxMailbox = await openBox();
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
      final boxMailbox = await openBox();
      return boxMailbox.deleteAll(listKey);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(Map<String, MailboxCache> mapObject) {
    return Future.sync(() async {
      final boxMailbox = await openBox();
      boxMailbox.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> clearAllData() {
    return Future.sync(() async {
      final boxMailbox = await openBox();
      boxMailbox.clear();
    }).catchError((error) {
      throw error;
    });
  }
}