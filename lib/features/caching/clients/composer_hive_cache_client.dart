import 'dart:convert';

import 'package:core/core.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/config/hive_cache_client.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/caching/utils/caching_constants.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_cache.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/data/model/composer_persistent_cache.dart';

class ComposerHiveCacheClient extends HiveCacheClient<String> {
  @override
  String get tableName => CachingConstants.composerHiveCacheBoxName;

  @override
  bool get encryption => true;

  String _entryKey(AccountId accountId, UserName userName, String? composerId) =>
      TupleKey(
        composerId ?? CachingConstants.composerHiveCacheKeyName,
        accountId.asString,
        userName.value,
      ).encodeKey;

  String _accountKey(AccountId accountId, UserName userName) =>
      TupleKey(accountId.asString, userName.value).encodeKey;

  ComposerPersistentCache? _decodeEntry(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return ComposerPersistentCache.fromJson(decoded);
      }
    } catch (e) {
      logWarning('ComposerHiveCacheClient::_decodeEntry: corrupted entry, skipping: ${e.runtimeType}');
    }
    return null;
  }

  Future<void> saveCache(
    AccountId accountId,
    UserName userName,
    ComposerCache cache,
  ) =>
      insertItem(
        _entryKey(accountId, userName, cache.composerId),
        jsonEncode(cache.toJson()),
      );

  Future<List<ComposerCache>> getCache(
    AccountId accountId,
    UserName userName,
  ) async {
    final rawList = await getListByNestedKey(_accountKey(accountId, userName));
    return rawList.map(_decodeEntry).nonNulls.toList();
  }

  Future<void> deleteCache(AccountId accountId, UserName userName) =>
      clearAllDataContainKey(_accountKey(accountId, userName));

  Future<void> deleteCacheById(
    AccountId accountId,
    UserName userName,
    String composerId,
  ) =>
      deleteItem(_entryKey(accountId, userName, composerId));
}
