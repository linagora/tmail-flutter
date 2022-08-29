
import 'package:core/core.dart';
import 'package:hive/hive.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';

class EmailCacheClient extends HiveCacheClient<EmailCache> {

  @override
  String get tableName => 'EmailCache';

  @override
  Future<Box<EmailCache>> openBox() async {
    if (Hive.isBoxOpen(tableName)) {
      return Hive.box<EmailCache>(tableName);
    }
    return Hive.openBox<EmailCache>(tableName);
  }

  @override
  Future<bool> isExistItem(String key) {
    return Future.sync(() async {
      final boxEmail = await openBox();
      return boxEmail.containsKey(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxEmail = await openBox();
      return boxEmail.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<EmailCache?> getItem(String key) {
    return Future.sync(() async {
      final boxEmail = await openBox();
      return boxEmail.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<EmailCache>> getAll() {
    return Future.sync(() async {
      final boxEmail = await openBox();
      return boxEmail.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertItem(String key, EmailCache newObject) {
    return Future.sync(() async {
      final boxEmail = await openBox();
      return boxEmail.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(Map<String, EmailCache> mapObject) {
    return Future.sync(() async {
      final boxEmail = await openBox();
      return boxEmail.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateItem(String key, EmailCache newObject) {
    return Future.sync(() async {
      final boxEmail = await openBox();
      return boxEmail.put(key, newObject);
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
  Future<void> deleteMultipleItem(List<String> listKey) {
    return Future.sync(() async {
      log('EmailCacheClient::deleteMultipleItem(): listKey: ${listKey.length}');
      final boxEmail = await openBox();
      return boxEmail.deleteAll(listKey);
    }).catchError((error) {
      log('EmailCacheClient::deleteMultipleItem(): error: $error');
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(Map<String, EmailCache> mapObject) {
    return Future.sync(() async {
      final boxEmail = await openBox();
      return boxEmail.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  Future<List<EmailCache>> getListEmailCacheByMailboxId(MailboxId mailboxId) {
    return Future.sync(() async {
      final boxEmail = await openBox();
      return boxEmail.values.where((emailCache) {
        return emailCache.mailboxIds != null
          && emailCache.mailboxIds!.containsKey(mailboxId.id.value)
          && emailCache.mailboxIds![mailboxId.id.value] == true;
      }).toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> clearAllData() {
    return Future.sync(() async {
      final boxEmail = await openBox();
      return boxEmail.clear();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteWhere(bool Function(EmailCache data) validate) {
    return Future.sync(() async {
      final boxEmail = await openBox();
      final emailIds = boxEmail.values.where(validate).map((email) => email.id);
      boxEmail.deleteAll(emailIds);
    }).catchError((error) {
      throw error;
    });
  }
}