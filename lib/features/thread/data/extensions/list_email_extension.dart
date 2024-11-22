
import 'package:jmap_dart_client/jmap/account_id.dart';
import 'package:jmap_dart_client/jmap/core/id.dart';
import 'package:jmap_dart_client/jmap/core/user_name.dart';
import 'package:jmap_dart_client/jmap/mail/email/email.dart';
import 'package:model/extensions/account_id_extensions.dart';
import 'package:model/extensions/email_id_extensions.dart';
import 'package:tmail_ui_user/features/caching/utils/cache_utils.dart';
import 'package:tmail_ui_user/features/thread/data/extensions/email_extension.dart';
import 'package:tmail_ui_user/features/thread/data/model/email_cache.dart';

extension ListEmailExtension on List<Email> {
  Map<String, EmailCache> toMapCache(AccountId accountId, UserName userName) {
    return {
      for (var email in this)
        TupleKey(email.id!.asString, accountId.asString, userName.value).encodeKey : email.toEmailCache()
    };
  }

  List<Email> sortEmailsById(List<Id> referenceIds) {
    final indexMap = {
      for (var i = 0; i < referenceIds.length; i++)
        referenceIds[i]: i
    };

    sort((email1, email2) {
      final indexEmail1 = indexMap[email1.id!.id] ?? double.maxFinite;
      final indexEmail2 = indexMap[email2.id!.id] ?? double.maxFinite;

      return indexEmail1.compareTo(indexEmail2);
    });

    return this;
  }
}