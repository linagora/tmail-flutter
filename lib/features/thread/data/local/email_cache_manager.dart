
import 'package:model/model.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:jmap_dart_client/jmap/mail/mailbox/mailbox.dart';
import 'package:tmail_ui_user/features/caching/email_cache_client.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_cache_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/list_email_cache_extension.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';
import 'package:jmap_dart_client/jmap/core/sort/comparator.dart';

class EmailCacheManager {

  final EmailCacheClient _emailCacheClient;

  EmailCacheManager(this._emailCacheClient);

  Future<List<Email>> getAllEmail({MailboxId? inMailboxId, Set<Comparator>? sort}) async {
    final emailCacheList = inMailboxId != null
      ? await _emailCacheClient.getListEmailCacheByMailboxId(inMailboxId)
      : await _emailCacheClient.getAll();
    final emailList = emailCacheList.map((emailCache) => emailCache.toEmail()).toList();
    if (sort != null) {
      sort.forEach((comparator) {
        emailList.sortBy(comparator);
      });
    }
    return emailList;
  }

  Future<void> update({List<Email>? updated, List<Email>? created, List<EmailId>? destroyed}) async {
    final emailCacheExist = await _emailCacheClient.isExistTable();
    if (emailCacheExist) {
      final updatedCacheEmails = updated
        ?.map((email) => email.toEmailCache()).toList() ?? <EmailCache>[];
      final createdCacheEmails = created
        ?.map((email) => email.toEmailCache()).toList() ?? <EmailCache>[];
      final destroyedCacheEmails = destroyed
        ?.map((emailId) => emailId.id.value).toList() ?? <String>[];
      await Future.wait([
        _emailCacheClient.updateMultipleItem(updatedCacheEmails.toMap()),
        _emailCacheClient.insertMultipleItem(createdCacheEmails.toMap()),
        _emailCacheClient.deleteMultipleItem(destroyedCacheEmails)
      ]);
    } else {
      final createdCacheEmails = created
        ?.map((email) => email.toEmailCache()).toList() ?? <EmailCache>[];
      await _emailCacheClient.insertMultipleItem(createdCacheEmails.toMap());
    }
  }


}