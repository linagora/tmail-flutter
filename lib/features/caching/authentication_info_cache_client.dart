import 'package:hive/hive.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/login/data/model/authentication_info_cache.dart';

class AuthenticationInfoCacheClient extends HiveCacheClient<AuthenticationInfoCache> {

  @override
  String get tableName => "AuthenticationInfoCache";

  @override
  Future<void> clearAllData() {
    return Future.sync(() async {
      final boxAuthenticationInfo = await openBox();
      return boxAuthenticationInfo.clear();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteItem(String key) {
    return Future.sync(() async {
      final boxAuthenticationInfo = await openBox();
      return boxAuthenticationInfo.delete(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> deleteMultipleItem(List<String> listKey) {
    return Future.sync(() async {
      final boxAuthenticationInfo = await openBox();
      return boxAuthenticationInfo.deleteAll(listKey);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<List<AuthenticationInfoCache>> getAll() {
    return Future.sync(() async {
      final boxAuthenticationInfo = await openBox();
      return boxAuthenticationInfo.values.toList();
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<AuthenticationInfoCache?> getItem(String key) {
    return Future.sync(() async {
      final boxAuthenticationInfo = await openBox();
      return boxAuthenticationInfo.get(key);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertItem(String key, AuthenticationInfoCache newObject) {
    return Future.sync(() async {
      final boxAuthenticationInfo = await openBox();
      return boxAuthenticationInfo.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> insertMultipleItem(Map<String, AuthenticationInfoCache> mapObject) {
    return Future.sync(() async {
      final boxAuthenticationInfo = await openBox();
      return boxAuthenticationInfo.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<bool> isExistItem(String key) {
    return Future.sync(() async {
      final boxAuthenticationInfo = await openBox();
      return boxAuthenticationInfo.containsKey(key);
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
  Future<Box<AuthenticationInfoCache>> openBox() async {
    return Future.sync(() async {
      final encryptionKey = await getEncryptionKey();
      return Hive.openBox<AuthenticationInfoCache>(
          tableName,
          encryptionCipher: HiveAesCipher(encryptionKey!));
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateItem(String key, AuthenticationInfoCache newObject) {
    return Future.sync(() async {
      final boxAuthenticationInfo = await openBox();
      return boxAuthenticationInfo.put(key, newObject);
    }).catchError((error) {
      throw error;
    });
  }

  @override
  Future<void> updateMultipleItem(Map<String, AuthenticationInfoCache> mapObject) {
    return Future.sync(() async {
      final boxAuthenticationInfo = await openBox();
      return boxAuthenticationInfo.putAll(mapObject);
    }).catchError((error) {
      throw error;
    });
  }
}