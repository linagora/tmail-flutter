
import 'package:collection/collection.dart';
import 'package:core/utils/app_logger.dart';
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/extensions/mailbox_extension.dart';
import 'package:tmail_ui_user/features/caching/clients/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/interaction/cache_manager_interaction.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/list_mailbox_cache_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/list_mailbox_extension.dart';
import 'package:tmail_ui_user/features/mailbox/data/extensions/list_mailbox_id_extension.dart';
import 'package:tmail_ui_user/features/mailbox_dashboard/domain/exceptions/spam_report_exception.dart';

class MailboxCacheManager extends CacheManagerInteraction {

  final MailboxCacheClient _mailboxCacheClient;

  MailboxCacheManager(this._mailboxCacheClient);

  Future<List<Mailbox>> getAllMailbox(AccountId accountId, UserName userName) async {
    final nestedKey = TupleKey(accountId.asString, userName.value).encodeKey;
    final mailboxCacheList = await _mailboxCacheClient.getListByNestedKey(nestedKey);
    return mailboxCacheList.toMailboxList();
  }

  Future<void> update(
    AccountId accountId,
    UserName userName, {
    List<Mailbox>? updated,
    List<Mailbox>? created,
    List<MailboxId>? destroyed
  }) async {
    if (created?.isNotEmpty == true) {
      final createdCacheMailboxes = created!.toMapCache(accountId, userName);
      await _mailboxCacheClient.insertMultipleItem(createdCacheMailboxes);
    }

    if (updated?.isNotEmpty == true) {
      final updatedCacheMailboxes = updated!.toMapCache(accountId, userName);
      await _mailboxCacheClient.updateMultipleItem(updatedCacheMailboxes);
    }

    if (destroyed?.isNotEmpty == true) {
      final destroyedCacheMailboxes = destroyed!.toCacheKeyList(accountId, userName);
      await _mailboxCacheClient.deleteMultipleItem(destroyedCacheMailboxes);
    }
  }

  Future<Mailbox> getSpamMailbox(AccountId accountId, UserName userName) async {
    final mailboxList = await getAllMailbox(accountId, userName);
    final spamMailbox = mailboxList.firstWhereOrNull((mailbox) => mailbox.isSpam);
    if (spamMailbox != null) {
      return spamMailbox;
    } else {
      throw NotFoundSpamMailboxCachedException();
    }
  }

  Future<void> deleteByKey(AccountId accountId, UserName userName) async {
    final nestedKey = TupleKey(accountId.asString, userName.value).encodeKey;
    await _mailboxCacheClient.clearAllDataContainKey(nestedKey);
  }

  Future<void> clear() => _mailboxCacheClient.clearAllData();

  @override
  Future<void> migrateHiveToIsolatedHive() async {
    try {
      final legacyMapItems = await _mailboxCacheClient.getMapItems(
        isolated: false,
      );
      log('$runtimeType::migrateHiveToIsolatedHive(): Length of legacyMapItems: ${legacyMapItems.length}');
      await _mailboxCacheClient.insertMultipleItem(legacyMapItems);
      log('$runtimeType::migrateHiveToIsolatedHive(): ✅ Migrate Hive box "${_mailboxCacheClient.tableName}" → IsolatedHive DONE');
    } catch (e) {
      logError('$runtimeType::migrateHiveToIsolatedHive(): ❌ Migrate Hive box "${_mailboxCacheClient.tableName}" → IsolatedHive FAILED, Error: $e');
    }
  }
}