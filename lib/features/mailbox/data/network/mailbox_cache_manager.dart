
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:model/model.dart';
import 'package:tmail_ui_user/features/caching/mailbox_cache_client.dart';
import 'package:tmail_ui_user/features/caching/state_cache_client.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_cache_response.dart';
import 'package:tmail_ui_user/features/mailbox/data/model/mailbox_change_response.dart';

class MailboxCacheManager {

  final MailboxCacheClient _mailboxCacheClient;
  final StateCacheClient _stateCacheClient;

  MailboxCacheManager(this._mailboxCacheClient, this._stateCacheClient);

  Future<MailboxCacheResponse> getAllMailbox() async {
    return await Future.wait(
      [
        _stateCacheClient.getItem(StateType.mailbox.value),
        _mailboxCacheClient.getListItem()
      ],
      eagerError: true
    ).then((List responses) {
      return MailboxCacheResponse(mailboxCaches: responses.last, oldState: responses.first);
    });
  }

  Future<MailboxChangeResponse> combineMailboxCache(MailboxChangeResponse mailboxChangeResponse, List<Mailbox> mailboxList) async {

    final mailboxUpdated = mailboxChangeResponse.updated;
    final updatedProperties = mailboxChangeResponse.updatedProperties;

    if (mailboxUpdated != null && mailboxUpdated.isNotEmpty) {
      final newListMailboxUpdated = mailboxUpdated.map((mailboxUpdated) {
        if (updatedProperties == null) {
          return mailboxUpdated;
        } else {
          final mailboxOld = findMailbox(mailboxUpdated.id, mailboxList);
          if (mailboxOld != null) {
            return mailboxOld.combineMailbox(mailboxUpdated, updatedProperties);
          } else {
            return mailboxUpdated;
          }
        }
      }).toList();

      final newMailboxChangeResponse = MailboxChangeResponse(
        created: mailboxChangeResponse.created,
        destroyed: mailboxChangeResponse.destroyed,
        updated: newListMailboxUpdated,
        newState: mailboxChangeResponse.newState,
        updatedProperties: mailboxChangeResponse.updatedProperties
      );

      return newMailboxChangeResponse;
    }
    return mailboxChangeResponse;
  }

  Mailbox? findMailbox(MailboxId mailboxId, List<Mailbox> mailboxList) {
    try {
      return mailboxList.firstWhere((element) => element.id == mailboxId);
    } catch (e) {
      return null;
    }
  }

  Future<void> asyncUpdateCache(MailboxChangeResponse mailboxChangeResponse) async {
    if (mailboxChangeResponse.newState != null) {
      final stateCacheExist = await _stateCacheClient.isExistTable();
      if (stateCacheExist) {
        _stateCacheClient.updateItem(
          StateType.mailbox.value,
          mailboxChangeResponse.newState!.toStateDao(StateType.mailbox));
      } else {
        _stateCacheClient.insertItem(
          StateType.mailbox.value,
          mailboxChangeResponse.newState!.toStateDao(StateType.mailbox));
      }
    }

    final mailboxCacheExist = await _mailboxCacheClient.isExistTable();
    if (mailboxCacheExist) {
      final updatedCacheMailboxes = mailboxChangeResponse.updated
        ?.map((mailbox) => mailbox.toMailboxCache())
        .toList() ?? <MailboxCache>[];
      final createdCacheMailboxes = mailboxChangeResponse.created
        ?.map((mailbox) => mailbox.toMailboxCache())
        .toList() ?? <MailboxCache>[];
      final destroyedCacheMailboxes = mailboxChangeResponse.destroyed
        ?.map((mailboxId) => mailboxId.id.value)
        .toList() ?? <String>[];
      await Future.wait([
        _mailboxCacheClient.updateMultipleItem(updatedCacheMailboxes.toMap()),
        _mailboxCacheClient.insertMultipleItem(createdCacheMailboxes.toMap()),
        _mailboxCacheClient.deleteMultipleItem(destroyedCacheMailboxes)
      ]);
    } else {
      final createdCacheMailboxes = mailboxChangeResponse.created
        ?.map((mailbox) => mailbox.toMailboxCache())
        .toList() ?? <MailboxCache>[];
      await _mailboxCacheClient.insertMultipleItem(createdCacheMailboxes.toMap());
    }
  }
}